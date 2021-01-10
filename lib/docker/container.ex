defmodule Docker.Container do
  alias Docker.Client
  alias Excontainers.WaitStrategy

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

  def start(container_id) do
    case Client.post("/containers/#{container_id}/start", %{}) do
      {:ok, %{status: 204}} -> :ok
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end

  def run(container_config, name \\ nil) do
    case create(container_config, name) do
      {:ok, container_id} ->
        start_and_wait(container_id, container_config)

      {:error, {:http_error, 404}} ->
        Docker.Api.pull_image(container_config.image)
        run(container_config)

      {:error, reason} ->
        {:error, reason}
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

  defp container_create_payload(container_config) do
    port_bindings_config =
      container_config.exposed_ports
      |> Enum.map(fn port -> {port, [%{"HostPort" => ""}]} end)
      |> Enum.into(%{})

    exposed_ports_config =
      container_config.exposed_ports
      |> Enum.map(fn port -> {port, %{}} end)
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
      HostConfig: %{PortBindings: port_bindings_config, Privileged: container_config.privileged, Binds: volume_bindings}
    }
    |> remove_nil_values
  end

  defp start_and_wait(container_id, container_config) do
    :ok = start(container_id)

    if container_config.wait_strategy do
      :ok = WaitStrategy.wait_until_container_is_ready(container_config.wait_strategy, container_id)
    end

    {:ok, container_id}
  end

  defp remove_nil_values(map) do
    map
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
  end
end
