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
    with_running_container(fn container_id ->
      expected_container_info = %Docker.Container{
        id: container_id, status: %Docker.Container.Status{state: :running, running: true}
      }

      assert {:ok, ^expected_container_info} = Docker.inspect_container(container_id)
    end)
  end

  test "inspect_container/1 returns error when container does not exist" do
    assert {:error, _} = Docker.inspect_container("unexisting-container-#{UUID.uuid4()}")
  end

  test "create_container/2 creates a container with the specified config" do
    unique_container_name = "test_create_container_#{UUID.uuid4()}"
    config = %Docker.ContainerConfig{image: "alpine:20201218", cmd: "sleep infinity"}
    on_exit(fn -> remove_container(unique_container_name) end)

    {:ok, container_id} = Docker.create_container(config, unique_container_name)

    {all_containers_output, _exit_code=0} = System.cmd("docker", ["ps", "-a"])
    assert all_containers_output =~ unique_container_name
    assert all_containers_output =~ String.slice(container_id, 1..11)
  end

  test "create_container/2 returns error when container configuration is invalid" do
    config = %Docker.ContainerConfig{image: "invalid image"}

    assert {:error, _} = Docker.create_container(config)
  end

  test "start_container/1 starts a created container" do
    with_created_container(fn container_id ->
      :ok = Docker.start_container(container_id)

      {running_containers_output, _exit_code=0} = System.cmd("docker", ["ps"])
      assert running_containers_output =~ String.slice(container_id, 1..11)
    end)
  end

  test "start_container/1 returns error when container does not exist" do
    assert {:error, _} = Docker.start_container("unexisting-container-#{UUID.uuid4()}")
  end

  defp mock_docker_host(mocked_value) do
    MockEnvironment
    |> expect(:get, fn ("DOCKER_HOST", _default) -> mocked_value end)
  end

  defp with_created_container(block) do
    {stdout, _exit_code=0} = System.cmd("docker", ["create", "alpine:20201218", "sleep", "infinity"])
    container_id = String.trim(stdout)
    on_exit(fn -> remove_container(container_id) end)

    block.(container_id)
  end

  defp with_running_container(block) do
    {stdout, _exit_code=0} = System.cmd("docker", ["run", "-d", "--rm", "alpine:20201218", "sleep", "infinity"])
    container_id = String.trim(stdout)
    on_exit(fn -> remove_container(container_id) end)

    block.(container_id)
  end

  defp remove_container(id_or_name), do: System.cmd("docker", ["rm", "-f", id_or_name])
end
