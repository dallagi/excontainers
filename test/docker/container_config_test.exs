defmodule Docker.ContainerConfigTest do
  use ExUnit.Case, async: true

  alias Docker.ContainerConfig

  test "can be modified with a builder-like approach" do
    config =
      %ContainerConfig{image: "my-image"}
      |> ContainerConfig.with_environment("key1", "val1")
      |> ContainerConfig.with_environment("key2", "val2")
      |> ContainerConfig.with_bind_mount("/host/src", "/container/dest")
      |> ContainerConfig.with_bind_mount("/another/host/src", "/another/container/dest")
      |> ContainerConfig.with_exposed_port(8080)
      |> ContainerConfig.with_exposed_port(8081)
      |> ContainerConfig.with_label("key1", "val1")
      |> ContainerConfig.with_label("key2", "val2")

    assert config == %Docker.ContainerConfig{
             bind_mounts: [
               %Docker.VolumeBinding{
                 container_dest: "/another/container/dest",
                 host_src: "/another/host/src",
                 options: "ro"
               },
               %Docker.VolumeBinding{
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
