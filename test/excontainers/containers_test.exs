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
end
