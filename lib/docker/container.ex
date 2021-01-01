defmodule Docker.Container do
  alias Docker.Client

  def create(container_config, name \\ nil) do
    data =
      %{Image: container_config.image, Cmd: container_config.cmd}
      |> Map.merge(port_mapping_configuration(container_config.exposed_ports))
      |> Map.merge(environment_configuration(container_config.environment))
      |> remove_nil_values

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

  def stop(container_id, options \\ [timeout_seconds: 10]) do
    query = %{t: options[:timeout_seconds]} |> remove_nil_values
    # enough to wait for container timeout
    http_timeout = (options[:timeout_seconds] + 1) * 1000

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

  defp port_mapping_configuration(exposed_ports) do
    exposed_ports_config =
      exposed_ports
      |> Enum.map(fn port -> {port, %{}} end)
      |> Enum.into(%{})

    port_bindings_config =
      exposed_ports
      |> Enum.map(fn port -> {port, [%{"HostPort" => ""}]} end)
      |> Enum.into(%{})

    %{
      ExposedPorts: exposed_ports_config,
      HostConfig: %{PortBindings: port_bindings_config}
    }
  end

  defp environment_configuration(nil), do: %{}
  defp environment_configuration(environment) do
    env_for_docker = environment
    |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)

    %{Env: env_for_docker}
  end

  def remove_nil_values(map) do
    map
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
  end
end
