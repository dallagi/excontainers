defmodule Docker.Container.Builder do
  alias Docker.{BindMount, Container}

  def new(image, opts \\ []) do
    exposed_ports =
      Keyword.get(opts, :exposed_ports, [])
      |> Enum.map(&set_protocol_to_tcp_if_not_specified/1)

    %Container{
      image: image,
      cmd: opts[:cmd],
      exposed_ports: exposed_ports,
      wait_strategy: opts[:wait_strategy],
      environment: opts[:environment] || %{},
      privileged: opts[:privileged] || false,
      bind_mounts: opts[:bind_mounts] || []
    }
  end

  def with_environment(config, key, value) do
    %Container{config | environment: Map.put(config.environment, key, value)}
  end

  def with_exposed_port(config, port) do
    %Container{config | exposed_ports: [port | config.exposed_ports]}
  end

  def with_bind_mount(config, host_src, container_dest, options \\ "ro") do
    new_bind_mount = %BindMount{host_src: host_src, container_dest: container_dest, options: options}
    %Container{config | bind_mounts: [new_bind_mount | config.bind_mounts]}
  end

  def with_label(config, key, value) do
    %Container{config | labels: Map.put(config.labels, key, value)}
  end

  defp set_protocol_to_tcp_if_not_specified(port) when is_binary(port), do: port
  defp set_protocol_to_tcp_if_not_specified(port) when is_integer(port), do: "#{port}/tcp"
end
