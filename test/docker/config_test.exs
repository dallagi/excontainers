defmodule Docker.ConfigTest do
  use ExUnit.Case, async: true

  test "returns DOCKER_HOST when it is set" do
    :ok = Gestalt.replace_env("DOCKER_HOST", "tcp://my-docker-host:1234", self())

    assert Docker.Config.docker_host() == "tcp://my-docker-host:1234"
  end

  test "returns default unix socket when DOCKER_HOST is not set" do
    :ok = Gestalt.replace_env("DOCKER_HOST", nil, self())

    assert Docker.Config.docker_host() == "unix:///var/run/docker.sock"
  end
end
