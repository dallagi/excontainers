defmodule DockerTest do
  use ExUnit.Case, async: true

  import Support.DockerTestUtils

  describe "ping/0" do
    test "returns :ok when communication with docker is successful" do
      assert Docker.ping() == :ok
    end

    test "returns error when communication with docker fails" do
      :ok = Gestalt.replace_env("DOCKER_HOST", "tcp://invalid-docker-host:1234", self())

      assert {:error, _} = Docker.ping()
    end
  end

  describe "inspect_container/1" do
    test "returns info about running container" do
      container_id = run_a_container()
      expected_container_info = %Docker.Container{
        id: container_id,
        status: %Docker.Container.Status{state: :running, running: true},
        mapped_ports: %{}
      }

      assert {:ok, ^expected_container_info} = Docker.inspect_container(container_id)
    end

    test "returns error when container does not exist" do
      assert {:error, _} = Docker.inspect_container("unexisting-container-#{UUID.uuid4()}")
    end
  end

  describe "create_container/2" do
    test "creates a container with the specified config" do
      unique_container_name = "test_create_container_#{UUID.uuid4()}"
      config = %Docker.ContainerConfig{image: "alpine:20201218", cmd: ["sleep", "infinity"]}
      on_exit(fn -> remove_container(unique_container_name) end)

      {:ok, container_id} = Docker.create_container(config, unique_container_name)

      {all_containers_output, _exit_code = 0} = System.cmd("docker", ["ps", "-a"])
      assert all_containers_output =~ unique_container_name
      assert all_containers_output =~ String.slice(container_id, 1..11)
    end

    test "supports mapping ports on the container to random ports on the host" do
      unique_container_name = "test_create_container_#{UUID.uuid4()}"

      config = %Docker.ContainerConfig{
        image: "alpine:20201218",
        cmd: ["sleep", "infinity"],
        exposed_ports: ["1234/tcp"]
      }

      on_exit(fn -> remove_container(unique_container_name) end)

      {:ok, container_id} = Docker.create_container(config, unique_container_name)

      System.cmd("docker", ["start", container_id])
      {container_port, _exit_code = 0} = System.cmd("docker", ["port", container_id])
      assert container_port =~ "1234/tcp"
    end

    test "supports setting environment variables" do
      config = %Docker.ContainerConfig{
        image: "alpine:20201218",
        cmd: ["sleep", "infinity"],
        environment: %{"TEST_VARIABLE" => "test value"}
      }

      {:ok, container_id} = Docker.create_container(config)
      on_exit(fn -> remove_container(container_id) end)

      System.cmd("docker", ["start", container_id])
      {stdout, _exit_code = 0} = System.cmd("docker", ["exec", container_id, "sh", "-c", "echo $TEST_VARIABLE"])
      assert stdout =~ "test value"
    end

    test "returns error when container configuration is invalid" do
      config = %Docker.ContainerConfig{image: "invalid image"}

      assert {:error, _} = Docker.create_container(config)
    end
  end

  describe "start_container/1" do
    test "starts a created container" do
      container_id = create_a_container()

      :ok = Docker.start_container(container_id)

      {running_containers_output, _exit_code = 0} = System.cmd("docker", ["ps"])
      assert running_containers_output =~ String.slice(container_id, 1..11)
    end

    test "returns error when container does not exist" do
      assert {:error, _} = Docker.start_container("unexisting-container-#{UUID.uuid4()}")
    end
  end

  describe "stop_container/1" do
    test "stops a running container" do
      container_id = run_a_container()
      :ok = Docker.stop_container(container_id, timeout_seconds: 1)

      {running_containers_output, _exit_code = 0} = System.cmd("docker", ["ps"])
      refute running_containers_output =~ String.slice(container_id, 1..11)
    end

    test "returns :ok and does nothing if container was already stopped" do
      container_id = create_a_container()
      :ok = Docker.stop_container(container_id)

      {running_containers_output, _exit_code = 0} = System.cmd("docker", ["ps"])
      refute running_containers_output =~ String.slice(container_id, 1..11)
    end

    test "returns error when container does not exist" do
      assert {:error, _} = Docker.stop_container("unexisting-container-#{UUID.uuid4()}")
    end
  end
end
