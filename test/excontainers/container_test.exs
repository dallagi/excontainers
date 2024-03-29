defmodule Excontainers.ContainerTest do
  use ExUnit.Case, async: true

  import Support.DockerTestUtils
  alias Excontainers.Container

  @sample_container_config Docker.Container.new("alpine:20201218", cmd: ["sleep", "infinity"])

  test "starts a container" do
    {:ok, pid} = Container.start_link(@sample_container_config)
    container_id = Container.container_id(pid)

    on_exit(fn -> remove_container(container_id) end)

    assert container_running?(container_id)
  end

  test "when terminating it stops a container" do
    {:ok, pid} = Container.start_link(@sample_container_config)
    container_id = Container.container_id(pid)

    Container.stop(pid)

    refute container_running?(container_id)
  end

  test "stores the container config" do
    {:ok, pid} = Container.start_link(@sample_container_config)

    assert Container.config(pid) == @sample_container_config
  end

  test "stores the id of the corresponding docker container, when running" do
    {:ok, pid} = Container.start_link(@sample_container_config)

    container_id = Container.container_id(pid)
    on_exit(fn -> remove_container(container_id) end)
    assert Container.container_id(pid) == container_id
  end

  describe "mapped_port" do
    @http_echo_container Docker.Container.new(
                           "hashicorp/http-echo:0.2.3",
                           cmd: ["-listen=:8080", ~s(-text="hello world")],
                           exposed_ports: [8080]
                         )

    test "gets the host port corresponding to a mapped port in the container" do
      {:ok, pid} = Container.start_link(@http_echo_container)
      container_id = Container.container_id(pid)
      on_exit(fn -> remove_container(container_id) end)

      port = Container.mapped_port(pid, 8080)

      {:ok, response} = Tesla.get("http://localhost:#{port}/")
      assert response.body =~ "hello world"
    end
  end
end
