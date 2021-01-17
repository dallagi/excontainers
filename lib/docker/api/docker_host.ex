defmodule Docker.Api.DockerHost do
  @moduledoc false

  use Gestalt

  @default_host "unix:///var/run/docker.sock"

  def detect do
    case gestalt_env("DOCKER_HOST", self()) do
      nil -> @default_host
      val -> val
    end
  end
end
