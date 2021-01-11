defmodule Docker.DockerHostTest do
  use ExUnit.Case, async: true

  alias Docker.Api.DockerHost

  test "detect/0 defaults to the default unix socket" do
    assert DockerHost.detect() == "unix:///var/run/docker.sock"
  end

  test "detect/0 returns content of $DOCKER_HOST environment variable" do
    :ok = Gestalt.replace_env("DOCKER_HOST", "tcp://1.2.3.4:1234", self())

    assert DockerHost.detect() == "tcp://1.2.3.4:1234"
  end
end
