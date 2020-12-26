defmodule Docker.DockerHost do
  @default_host "unix:///var/run/docker.sock"

  def detect do
    environment().get("DOCKER_HOST", @default_host)
  end

  defp environment, do: Application.get_env(:excontainers, :environment)
end
