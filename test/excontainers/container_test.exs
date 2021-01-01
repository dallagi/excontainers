defmodule Excontainers.ContainerTest do
  use ExUnit.Case, async: true

  alias Excontainers.Container

  describe "new/2" do
    test "creates container with given image" do
      assert Container.new("some-image") == %Docker.ContainerConfig{image: "some-image"}
    end

    test "when exposing ports, exposes them for TCP by default" do
      container_config = Container.new("any", exposed_ports: [1111, "2222/udp"])
      assert container_config.exposed_ports == ["1111/tcp", "2222/udp"]
    end
  end
end
