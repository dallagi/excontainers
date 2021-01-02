defmodule Docker.Client do
  use Tesla

  alias Docker.{DockerHost, HackneyHost}

  @api_version "v1.41"

  plug(Tesla.Middleware.BaseUrl, base_url())
  plug(Tesla.Middleware.JSON)
  adapter(Tesla.Adapter.Hackney)

  def plain_text do
    Tesla.client(
      [{Tesla.Middleware.BaseUrl, base_url()}],
      Tesla.Adapter.Hackney
    )
  end

  defp base_url, do: docker_host() <> "/" <> @api_version

  defp docker_host do
    HackneyHost.from_docker_host(DockerHost.detect())
  end
end
