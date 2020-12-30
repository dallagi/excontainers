defmodule Excontainers.ContainerTest do
  use ExUnit.Case, async: true

  alias Excontainers.Container

  describe "new/2" do
    test "creates container with given image" do
      assert Container.new("some-image") == %Docker.ContainerConfig{image: "some-image"}
    end

    test "when exposing ports, exposes them for TCP by default" do
      expected_config = %Docker.ContainerConfig{image: "some-image", exposed_ports: ["1111/tcp", "2222/udp"]}
      assert Container.new("some-image", exposed_ports: [1111, "2222/udp"]) == expected_config
    end
  end
end
