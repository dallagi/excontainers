defmodule Docker.HackneyHostTest do
  use ExUnit.Case, async: true

  alias Docker.HackneyHost

  test "tcp docker hosts are converted to http hosts for hackney" do
    assert HackneyHost.from_docker_host("tcp://my-host:1234") == "http://my-host:1234"
  end

  test "unix socket docker hosts are converted to http+unix hosts for hackney, and the socket path is url-encoded" do
    assert HackneyHost.from_docker_host("unix:///var/run/docker.sock") == "http+unix://%2Fvar%2Frun%2Fdocker.sock"
  end
end
