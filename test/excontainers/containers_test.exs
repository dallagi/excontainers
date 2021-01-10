defmodule Excontainers.ContainersTest do
  use ExUnit.Case, async: true

  import Support.DockerTestUtils
  alias Excontainers.Containers

  describe "new/2" do
    test "creates container with given image" do
      assert Containers.new("some-image") == %Docker.ContainerConfig{image: "some-image"}
    end

    test "when exposing ports, exposes them for TCP by default" do
      container_config = Containers.new("any", exposed_ports: [1111, "2222/udp"])
      assert container_config.exposed_ports == ["1111/tcp", "2222/udp"]
    end
  end

  describe "mapped_port/2" do
    test "gets the host port corresponding to a mapped port in the container" do
      container_id =
        run_a_container(
          "hashicorp/http-echo:0.2.3",
          ["-listen=:8080", ~s(-text="hello world")],
          "8080"
        )

      port = Containers.mapped_port(container_id, 8080)
      {:ok, response} = Tesla.get("http://localhost:#{port}/")

      assert is_integer(port)
      assert response.body =~ "hello world"
    end
  end

  defp run_a_container(image, cmd, exposed_port) do
    {stdout, _exit_code = 0} = System.cmd("docker", ["run", "-d", "--rm", "-p", exposed_port, image] ++ cmd)

    container_id = String.trim(stdout)
    on_exit(fn -> remove_container(container_id) end)

    container_id
  end
end
