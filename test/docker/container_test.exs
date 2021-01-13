defmodule Docker.ContainerTest do
  use ExUnit.Case, async: true

  alias Docker.Container

  describe "new/2" do
    test "creates container with given image" do
      assert Container.new("some-image") == %Docker.Container{image: "some-image"}
    end

    test "when exposing ports, exposes them for TCP by default" do
      container_config = Container.new("any", exposed_ports: [1111, "2222/udp"])
      assert container_config.exposed_ports == ["1111/tcp", "2222/udp"]
    end
  end

  test "can be modified with a builder-like approach" do
    config =
      %Container{image: "my-image"}
      |> Container.with_environment("key1", "val1")
      |> Container.with_environment("key2", "val2")
      |> Container.with_bind_mount("/host/src", "/container/dest")
      |> Container.with_bind_mount("/another/host/src", "/another/container/dest")
      |> Container.with_exposed_port(8080)
      |> Container.with_exposed_port(8081)
      |> Container.with_label("key1", "val1")
      |> Container.with_label("key2", "val2")

    assert config == %Docker.Container{
             bind_mounts: [
               %Docker.BindMount{
                 container_dest: "/another/container/dest",
                 host_src: "/another/host/src",
                 options: "ro"
               },
               %Docker.BindMount{
                 container_dest: "/container/dest",
                 host_src: "/host/src",
                 options: "ro"
               }
             ],
             cmd: nil,
             environment: %{"key1" => "val1", "key2" => "val2"},
             exposed_ports: [8081, 8080],
             image: "my-image",
             privileged: false,
             labels: %{"key2" => "val2", "key1" => "val1"},
             wait_strategy: nil
           }
  end
end
