defmodule Docker do
  use Tesla

  plug Tesla.Middleware.BaseUrl, Docker.Host.detect()
  plug Tesla.Middleware.JSON
  adapter Tesla.Adapter.Hackney

  def xxx() do
    get("/v1.41/info")
  end
end
