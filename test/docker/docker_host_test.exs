defmodule Docker.DockerHostTest do
  use ExUnit.Case, async: true
  import Mox

  alias Docker.DockerHost

  setup do
    Mox.stub_with(MockEnvironment, Support.StubEnvironment)
    verify_on_exit!()
  end

  test "detect/0 defaults to the default unix socket" do
    assert DockerHost.detect() == "unix:///var/run/docker.sock"
  end

  test "detect/0 returns content of $DOCKER_HOST environment variable" do
    MockEnvironment
    |> expect(:get, fn ("DOCKER_HOST", _default) -> "tcp://1.2.3.4:1234" end)

    assert DockerHost.detect() == "tcp://1.2.3.4:1234"
  end
end
