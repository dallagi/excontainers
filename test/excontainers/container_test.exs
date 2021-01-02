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
end
