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

  test "inspect_container/1 returns info about running container" do
    with_container(fn container_id ->
      expected_container_info =
        %Docker.Container{id: container_id, status: %Docker.Container.Status{state: :running, running: true}}

      assert {:ok, ^expected_container_info} = Docker.inspect_container(container_id)
    end)
  end

  defp mock_docker_host(mocked_value) do
    MockEnvironment
    |> expect(:get, fn ("DOCKER_HOST", _default) -> mocked_value end)
  end

  defp with_container(block) do
    {stdout, _exit_code=0} = System.cmd("docker", ["run", "-d", "--rm", "alpine", "sleep", "infinity"])
    container_id = String.trim(stdout)
    on_exit(fn -> kill_container(container_id) end)

    block.(container_id)
  end

  defp kill_container(id), do: System.cmd("docker", ["kill", id])
end
