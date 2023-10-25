defmodule Docker.Containers do
  @moduledoc false
  alias Docker.WaitStrategy

  def create(container_config, name \\ nil) do
    Docker.Api.create_container(container_config, name)
  end

  def run(container_config, name \\ nil) do
    case Docker.Api.create_container(container_config, name) do
      {:ok, container_id} ->
        start_and_wait(container_id, container_config)

      {:error, {:http_error, 404}} ->
        Docker.Images.pull(container_config.image)
        run(container_config)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def start(container_id) do
    Docker.Api.start_container(container_id)
  end

  def stop(container_id, options \\ []) do
    Docker.Api.stop_container(container_id, options)
  end

  def delete_stopped() do
    Docker.Api.delete_stopped()
  end

  def info(container_id), do: Docker.Api.inspect_container(container_id)

  def mapped_port(container, container_port) do
    container_port =
      container_port
      |> set_protocol_to_tcp_if_not_specified

    case info(container) do
      {:ok, info} ->
        port =
          info.mapped_ports
          |> Map.get(container_port)
          |> String.to_integer()

        {:ok, port}

      {:error, message} ->
        {:error, message}
    end
  end

  defp set_protocol_to_tcp_if_not_specified(port) when is_binary(port), do: port
  defp set_protocol_to_tcp_if_not_specified(port) when is_integer(port), do: "#{port}/tcp"

  defp start_and_wait(container_id, container_config) do
    :ok = Docker.Containers.start(container_id)

    if container_config.wait_strategy do
      :ok = WaitStrategy.wait_until_container_is_ready(container_config.wait_strategy, container_id)
    end

    {:ok, container_id}
  end
end
