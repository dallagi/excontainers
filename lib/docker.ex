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
      {:ok, response} -> {:ok, parse_container_info(response.body)}
      {:error, message} -> {:error, message}
    end
  end

  defp docker_host do
    HackneyHost.from_docker_host(DockerHost.detect())
  end

  defp base_url, do: "/" <> @api_version

  defp parse_container_info(json_info) do
    %Container{
      id: json_info["Id"],
      status: %Container.Status{
        state: Container.Status.parse_status(json_info["State"]["Status"]),
        running: json_info["State"]["Running"]
      }
    }
  end
end
