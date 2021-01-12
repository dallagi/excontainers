defmodule Excontainers.Containers do
  @moduledoc """
  High-level functions to interact with Docker.
  """

  def new(image, opts \\ []) do
    exposed_ports =
      Keyword.get(opts, :exposed_ports, [])
      |> Enum.map(&set_protocol_to_tcp_if_not_specified/1)

    %Docker.ContainerConfig{
      image: image,
      cmd: opts[:cmd],
      exposed_ports: exposed_ports,
      wait_strategy: opts[:wait_strategy],
      environment: opts[:environment] || %{},
      privileged: opts[:privileged] || false,
      bind_mounts: opts[:bind_mounts] || []
    }
  end

  def stop(container_id, opts \\ []), do: Docker.Api.stop_container(container_id, opts)

  defp set_protocol_to_tcp_if_not_specified(port) when is_binary(port), do: port
  defp set_protocol_to_tcp_if_not_specified(port) when is_integer(port), do: "#{port}/tcp"
end
