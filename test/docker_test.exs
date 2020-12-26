defmodule DockerTest do
  use ExUnit.Case, async: true
  import Mox

  setup do
    Mox.stub_with(MockEnvironment, Support.StubEnvironment)
    :ok
  end

  test "ping/0 returns :ok when communication with docker is successful" do
    assert Docker.ping() == :ok
  end

  test "ping/0 returns {:error, message} when communication with docker fails" do
    mock_docker_host("tcp://invalid-docker-host:1234")

    assert {:error, _} = Docker.ping()
  end

  defp mock_docker_host(mocked_value) do
    MockEnvironment
    |> expect(:get, fn ("DOCKER_HOST", _default) -> mocked_value end)
  end
end
