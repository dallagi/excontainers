defmodule Docker.ContainerConfig do
  alias Docker.VolumeBinding

  @enforce_keys [:image]
  defstruct [
    :image,
    cmd: nil,
    environment: %{},
    exposed_ports: [],
    wait_strategy: nil,
    privileged: false,
    bind_mounts: []
  ]

  def with_environment(config, key, value) do
    %__MODULE__{config | environment: Map.put(config.environment, key, value)}
  end

  def with_exposed_port(config, port) do
    %__MODULE__{config | exposed_ports: [port | config.exposed_ports]}
  end

  def with_bind_mount(config, host_src, container_dest, options \\ "ro") do
    new_bind_mount = %VolumeBinding{host_src: host_src, container_dest: container_dest, options: options}
    %__MODULE__{config | bind_mounts: [ new_bind_mount | config.bind_mounts ]}
  end
 end
