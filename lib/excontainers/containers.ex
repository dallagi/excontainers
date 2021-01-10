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

  def info(container_id), do: Docker.Api.inspect_container(container_id)

  def mapped_port(container, container_port) do
    container_port =
      container_port
      |> set_protocol_to_tcp_if_not_specified

    case info(container) do
      {:ok, info} ->
        info.mapped_ports
        |> Map.get(container_port)
        |> String.to_integer()

      {:error, message} ->
        {:error, message}
    end
  end

  defp set_protocol_to_tcp_if_not_specified(port) when is_binary(port), do: port
  defp set_protocol_to_tcp_if_not_specified(port) when is_integer(port), do: "#{port}/tcp"
end
