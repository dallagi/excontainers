defmodule Docker do
  @api_version "v1.41"
  use Tesla

  alias Docker.{Container, DockerHost, HackneyHost}

  plug Tesla.Middleware.BaseUrl, docker_host()
  plug Tesla.Middleware.JSON
  adapter Tesla.Adapter.Hackney

  def ping() do
    case get(base_url() <> "/info") do
      {:ok, _response} -> :ok
      {:error, message} -> {:error, message}
    end
  end

  def inspect_container(container_id) do
    case get(base_url() <> "/containers/#{container_id}/json") do
      {:ok, response} -> {:ok, Container.parse_docker_response(response.body)}
      {:error, message} -> {:error, message}
    end
  end

  def create_container(container_config, name \\ nil) do
    data = %{Image: container_config.image, Cmd: container_config.cmd}
           |> remove_nil_values
    query = %{name: name}
            |> remove_nil_values

    case post(base_url() <> "/containers/create", data, query: query) do
      {:ok, response} -> {:ok, response.body["Id"]}
      {:error, message} -> {:error, message}
    end
  end

  def start_container(container_id) do
    case post(base_url() <> "/containers/#{container_id}/start", %{}) do
      {:ok, response} -> case response.status do
        204 -> :ok
        status -> {:error, "Request failed with status code #{status}"}
      end
      {:error, message} -> {:error, message}
    end
  end

  defp docker_host do
    HackneyHost.from_docker_host(DockerHost.detect())
  end

  defp base_url, do: "/" <> @api_version

  def remove_nil_values(map) do
    map
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
  end
end
