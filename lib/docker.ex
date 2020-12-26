defmodule Docker do
  use Tesla

  alias Docker.{DockerHost, HackneyHost}

  plug Tesla.Middleware.BaseUrl, docker_host()
  plug Tesla.Middleware.JSON
  adapter Tesla.Adapter.Hackney

  def xxx() do
    get("/v1.41/info")
  end

  defp docker_host do
    HackneyHost.from_docker_host(DockerHost.detect())
  end
end
