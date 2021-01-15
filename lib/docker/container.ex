defmodule Docker.Container do
  alias Docker.{BindMount, Container}

  @enforce_keys [:image]

  defstruct [
    :image,
    cmd: nil,
    environment: %{},
    exposed_ports: [],
    wait_strategy: nil,
    privileged: false,
    bind_mounts: [],
    labels: %{}
  ]

  @doc """
  Creates a _container_ from the given image.

  ## Options

  - `bind_mounts` sets the files or the directories on the _host machine_ to mount into the _container_.
  - `cmd` sets the command to run in the container
  - `environment` sets the environment variables for the container
  - `exposed_ports` sets the ports to expose to the host
  - `privileged` indicates whether the container should run in privileged mode
  - `wait_strategy` sets the strategy to adopt to determine whether the container is ready for use

  """
  def new(image, opts \\ []) do
    exposed_ports =
      Keyword.get(opts, :exposed_ports, [])
      |> Enum.map(&set_protocol_to_tcp_if_not_specified/1)

    %Container{
      image: image,
      bind_mounts: opts[:bind_mounts] || [],
      cmd: opts[:cmd],
      environment: opts[:environment] || %{},
      exposed_ports: exposed_ports,
      privileged: opts[:privileged] || false,
      wait_strategy: opts[:wait_strategy]
    }
  end

  @doc """
  Sets an _environment variable_ to the _container_.
  """
  def with_environment(config, key, value) do
    %Container{config | environment: Map.put(config.environment, key, value)}
  end

  @doc """
  Adds a _port_ to be exposed on the _container_.
  """
  def with_exposed_port(config, port) do
    %Container{config | exposed_ports: [port | config.exposed_ports]}
  end

  @doc """
  Sets a file or the directory on the _host machine_ to be mounted into a _container_.
  """
  def with_bind_mount(config, host_src, container_dest, options \\ "ro") do
    new_bind_mount = %BindMount{host_src: host_src, container_dest: container_dest, options: options}
    %Container{config | bind_mounts: [new_bind_mount | config.bind_mounts]}
  end

  @doc """
  Sets a label to apply to the container object in docker.
  """
  def with_label(config, key, value) do
    %Container{config | labels: Map.put(config.labels, key, value)}
  end

  defp set_protocol_to_tcp_if_not_specified(port) when is_binary(port), do: port
  defp set_protocol_to_tcp_if_not_specified(port) when is_integer(port), do: "#{port}/tcp"
end
