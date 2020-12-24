defmodule Docker do
  use Tesla
  @docker_host "/var/run/docker.sock"

  plug Tesla.Middleware.BaseUrl, "http+unix://#{:http_uri.encode(@docker_host)}" # todo: support tcp $DOCKER_HOST
  plug Tesla.Middleware.JSON
  adapter Tesla.Adapter.Hackney

  def xxx() do
    get("/v1.41/info")
  end
end
