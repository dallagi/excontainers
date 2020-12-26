defmodule Docker do
  use Tesla

  alias Docker.{DockerHost, HackneyHost}

  plug Tesla.Middleware.BaseUrl, docker_host()
  plug Tesla.Middleware.JSON
  adapter Tesla.Adapter.Hackney

  def ping() do
    case get("/v1.41/info") do
      {:ok, _response} -> :ok
      {:error, message} -> {:error, message}
    end
  end

  defp docker_host do
    HackneyHost.from_docker_host(DockerHost.detect())
  end
end
