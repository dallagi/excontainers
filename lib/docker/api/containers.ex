defmodule Docker.Api.Containers do
  @moduledoc false

  alias Docker.Api.Client
  alias Docker.ContainerState

  def create(container_config, name \\ nil) do
    data = container_create_payload(container_config)

    query =
      %{name: name}
      |> remove_nil_values

    case Client.post("/containers/create", data, query: query) do
      {:ok, %{status: 201, body: body}} -> {:ok, body["Id"]}
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end

  def start(container_id, options \\ []) do
    timeout_seconds = Keyword.get(options, :timeout_seconds, 300)
    # enough to wait for container timeout
    http_timeout = (timeout_seconds + 1) * 1000

    case Client.post(
           "/containers/#{container_id}/start",
           %{},
           opts: [adapter: [recv_timeout: http_timeout]]
         ) do
      {:ok, %{status: 204}} -> :ok
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end

  def stop(container_id, options \\ []) do
    timeout_seconds = Keyword.get(options, :timeout_seconds, 10)
    # enough to wait for container timeout
    http_timeout = (timeout_seconds + 1) * 1000

    query = %{t: timeout_seconds} |> remove_nil_values

    case Client.post(
           "/containers/#{container_id}/stop",
           %{},
           query: query,
           opts: [adapter: [recv_timeout: http_timeout]]
         ) do
      {:ok, %{status: status}} when status in [204, 304] -> :ok
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end

  def inspect(container_id) do
    case Client.get("/containers/#{container_id}/json") do
      {:ok, %{status: 200, body: body}} -> {:ok, ContainerState.parse_docker_response(body)}
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end

  defp container_create_payload(container_config) do
    port_bindings_config =
      container_config.exposed_ports
      |> Enum.map(fn
        {container_port, host_port} -> {container_port, [%{"HostPort" => to_string(host_port)}]}
        port -> {port, [%{"HostPort" => ""}]}
      end)
      |> Enum.into(%{})

    exposed_ports_config =
      container_config.exposed_ports
      |> Enum.map(fn
        {container_port, _host_port} -> {container_port, %{}}
        port -> {port, %{}}
      end)
      |> Enum.into(%{})

    env_config =
      container_config.environment
      |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)

    volume_bindings =
      container_config.bind_mounts
      |> Enum.map(fn volume_binding ->
        "#{volume_binding.host_src}:#{volume_binding.container_dest}:#{volume_binding.options}"
      end)

    %{
      Image: container_config.image,
      Cmd: container_config.cmd,
      ExposedPorts: exposed_ports_config,
      Env: env_config,
      Labels: container_config.labels,
      HostConfig: %{
        AutoRemove: container_config.auto_remove,
        PortBindings: port_bindings_config,
        Privileged: container_config.privileged,
        Binds: volume_bindings
      }
    }
    |> remove_nil_values
  end

  defp remove_nil_values(map) do
    map
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
  end
end
