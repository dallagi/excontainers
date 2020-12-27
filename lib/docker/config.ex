defmodule Docker.Config do
  use Gestalt

  @default_docker_host "unix:///var/run/docker.sock"

  def docker_host do
    case gestalt_env("DOCKER_HOST", self()) do
      nil -> @default_docker_host
      val -> val
    end
  end
end
