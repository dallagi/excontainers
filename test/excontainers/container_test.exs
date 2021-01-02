defmodule Excontainers.ContainerTest do
  use ExUnit.Case, async: true

  alias Excontainers.{Container, Containers}

  @sample_container_config Containers.new("alpine", cmd: ["sleep", "infinity"])

  test "starts a container" do
    {:ok, pid} = Container.start_link(@sample_container_config)

    {:ok, container_id} = Container.start(pid)

    {running_containers_output, _exit_code = 0} = System.cmd("docker", ["ps"])
    assert running_containers_output =~ String.slice(container_id, 1..11)
  end

  test "stops a container" do
    {:ok, pid} = Container.start_link(@sample_container_config)
    {:ok, container_id} = Container.start(pid)

    :ok = Container.stop(pid)

    {running_containers_output, _exit_code = 0} = System.cmd("docker", ["ps"])
    refute running_containers_output =~ String.slice(container_id, 1..11)
  end

  test "stores the container config" do
    {:ok, pid} = Container.start_link(@sample_container_config)

    assert Container.config(pid) == @sample_container_config
  end

  test "stores the id of the corresponding docker container, when running" do
    {:ok, pid} = Container.start_link(@sample_container_config)
    assert Container.container_id(pid) == nil

    {:ok, container_id} = Container.start(pid)
    assert Container.container_id(pid) == container_id
  end

  describe "mapped_port" do
    @http_echo_container Containers.new(
                           "hashicorp/http-echo:0.2.3",
                           cmd: ["-listen=:8080", ~s(-text="hello world")],
                           exposed_ports: [8080]
                         )

    test "gets the host port corresponding to a mapped port in the container" do
      {:ok, pid} = Container.start_link(@http_echo_container)
      {:ok, _container_id} = Container.start(pid)

      port = Container.mapped_port(pid, 8080)

      {:ok, response} = Tesla.get("http://localhost:#{port}/")
      assert response.body =~ "hello world"
    end
  end
end
