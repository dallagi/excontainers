defmodule Excontainers.Containers do
  @moduledoc """
  High-level functions to interact with Docker.
  """
  alias Excontainers.WaitStrategy

  def new(image, opts \\ []) do
    exposed_ports =
      Keyword.get(opts, :exposed_ports, [])
      |> Enum.map(&set_protocol_to_tcp_if_not_specified/1)

    %Docker.ContainerConfig{
      image: image,
      cmd: opts[:cmd],
      exposed_ports: exposed_ports,
      wait_strategy: opts[:wait_strategy],
      environment: opts[:environment] || %{}
    }
  end

  def start(container_config) do
    case Docker.Api.create_container(container_config) do
      {:ok, container_id} -> do_start(container_id, container_config)
      {:error, {:http_error, 404}} ->
        Docker.Api.pull_image(container_config.image)
        start(container_config)
    end
  end

  def stop(container_id, opts \\ []), do: Docker.Api.stop_container(container_id, opts)

  def info(container_id) do
    {:ok, container_info} = Docker.Api.inspect_container(container_id)

    container_info
  end

  defp do_start(container_id, container_config) do
    :ok = Docker.Api.start_container(container_id)
    if container_config.wait_strategy do
      :ok = WaitStrategy.wait_until_container_is_ready(container_config.wait_strategy, container_id)
    end
    {:ok, container_id}
  end

  def mapped_port(container, container_port) do
    container_port = set_protocol_to_tcp_if_not_specified(container_port)
    info(container).mapped_ports[container_port]
  end

  defp set_protocol_to_tcp_if_not_specified(port) when is_binary(port), do: port
  defp set_protocol_to_tcp_if_not_specified(port) when is_integer(port), do: "#{port}/tcp"

  defp lookup_container(container_name), do: Excontainers.Agent.lookup_container(container_name)
end