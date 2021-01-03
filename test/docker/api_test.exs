defmodule Docker.ApiTest do
  use ExUnit.Case, async: true

  alias Docker.{Api, ContainerConfig, ContainerState}
  import Support.DockerTestUtils

  describe "ping/0" do
    test "returns :ok when communication with docker is successful" do
      assert Api.ping() == :ok
    end

    test "returns error when communication with docker fails" do
      :ok = Gestalt.replace_env("DOCKER_HOST", "tcp://invalid-docker-host:1234", self())

      assert {:error, _} = Api.ping()
    end
  end

  describe "inspect_container/1" do
    test "returns info about running container" do
      container_id = run_a_container()

      expected_container_info = %ContainerState{
        id: container_id,
        status: %ContainerState.Status{state: :running, running: true},
        mapped_ports: %{}
      }

      assert {:ok, ^expected_container_info} = Api.inspect_container(container_id)
    end

    test "returns error when container does not exist" do
      assert {:error, _} = Api.inspect_container("unexisting-container-#{UUID.uuid4()}")
    end
  end

  describe "create_container/2" do
    test "creates a container with the specified config" do
      unique_container_name = "test_create_container_#{UUID.uuid4()}"
      config = %ContainerConfig{image: "alpine:20201218", cmd: ["sleep", "infinity"]}
      on_exit(fn -> remove_container(unique_container_name) end)

      {:ok, container_id} = Api.create_container(config, unique_container_name)

      {all_containers_output, _exit_code = 0} = System.cmd("docker", ["ps", "-a"])
      assert all_containers_output =~ unique_container_name
      assert all_containers_output =~ short_id(container_id)
    end

    test "supports mapping ports on the container to random ports on the host" do
      unique_container_name = "test_create_container_#{UUID.uuid4()}"

      config = %ContainerConfig{
        image: "alpine:20201218",
        cmd: ["sleep", "infinity"],
        exposed_ports: ["1234/tcp"]
      }

      on_exit(fn -> remove_container(unique_container_name) end)

      {:ok, container_id} = Api.create_container(config, unique_container_name)

      System.cmd("docker", ["start", container_id])
      {container_port, _exit_code = 0} = System.cmd("docker", ["port", container_id])
      assert container_port =~ "1234/tcp"
    end

    test "supports setting environment variables" do
      config = %ContainerConfig{
        image: "alpine:20201218",
        cmd: ["sleep", "infinity"],
        environment: %{"TEST_VARIABLE" => "test value"}
      }

      {:ok, container_id} = Api.create_container(config)
      on_exit(fn -> remove_container(container_id) end)

      System.cmd("docker", ["start", container_id])
      {stdout, _exit_code = 0} = System.cmd("docker", ["exec", container_id, "sh", "-c", "echo $TEST_VARIABLE"])
      assert stdout =~ "test value"
    end

    test "supports setting containers as privileged" do
      config = %ContainerConfig{image: "alpine:20201218", privileged: true}

      {:ok, container_id} = Api.create_container(config)

      {container_info, _exit_code = 0} = System.cmd("docker", ["inspect", container_id])
      assert container_info =~ ~s("Privileged": true)
    end

    test "returns error when container configuration is invalid" do
      config = %ContainerConfig{image: "invalid image"}

      assert {:error, _} = Api.create_container(config)
    end
  end

  describe "start_container/1" do
    test "starts a created container" do
      container_id = create_a_container()

      :ok = Api.start_container(container_id)

      {running_containers_output, _exit_code = 0} = System.cmd("docker", ["ps"])
      assert running_containers_output =~ short_id(container_id)
    end

    test "returns error when container does not exist" do
      assert {:error, _} = Api.start_container("unexisting-container-#{UUID.uuid4()}")
    end
  end

  describe "stop_container/1" do
    test "stops a running container" do
      container_id = run_a_container()
      :ok = Api.stop_container(container_id, timeout_seconds: 1)

      {running_containers_output, _exit_code = 0} = System.cmd("docker", ["ps"])
      refute running_containers_output =~ short_id(container_id)
    end

    test "returns :ok and does nothing if container was already stopped" do
      container_id = create_a_container()
      :ok = Api.stop_container(container_id)

      {running_containers_output, _exit_code = 0} = System.cmd("docker", ["ps"])
      refute running_containers_output =~ short_id(container_id)
    end

    test "returns error when container does not exist" do
      assert {:error, _} = Api.stop_container("unexisting-container-#{UUID.uuid4()}")
    end
  end

  describe "pull_image/1" do
    test "pulls the image if it does not exist" do
      image_that_no_one_should_be_using = "busybox:1.24.2-uclibc"
      remove_image(image_that_no_one_should_be_using)

      refute image_exists?(image_that_no_one_should_be_using)

      :ok = Api.pull_image(image_that_no_one_should_be_using)

      assert image_exists?(image_that_no_one_should_be_using)
    end

    test "returns error when image does not exist" do
      assert {:error, _} = Api.stop_container("unexisting-image-#{UUID.uuid4()}")
    end
  end
end
