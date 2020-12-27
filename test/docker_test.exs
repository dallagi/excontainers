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
      expected_container_info = %Docker.ContainerInfo{
        id: container_id, status: %Docker.ContainerInfo.Status{state: :running, running: true}
      }

      assert {:ok, ^expected_container_info} = Docker.inspect_container(container_id)
    end)
  end

  test "create_container/1 runs a container and returns its id" do
    unique_container_name = "test_create_container_#{UUID.uuid4()}"
    container = %Docker.Container{name: unique_container_name, image: "alpine:20201218", cmd: "sleep infinity"}
    on_exit(fn -> remove_container(unique_container_name) end)

    {:ok, container_id} = Docker.create_container(container)

    {docker_ps_output, _exit_code=0} = System.cmd("docker", ["ps", "-a"])
    assert docker_ps_output =~ unique_container_name
    assert docker_ps_output =~ String.slice(container_id, 1..11)
  end

  defp mock_docker_host(mocked_value) do
    MockEnvironment
    |> expect(:get, fn ("DOCKER_HOST", _default) -> mocked_value end)
  end

  defp with_container(block) do
    {stdout, _exit_code=0} = System.cmd("docker", ["run", "-d", "--rm", "alpine:20201218", "sleep", "infinity"])
    container_id = String.trim(stdout)
    on_exit(fn -> remove_container(container_id) end)

    block.(container_id)
  end

  defp remove_container(id_or_name), do: System.cmd("docker", ["rm", "-f", id_or_name])
end
