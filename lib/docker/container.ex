defmodule Docker.Container do
  alias Excontainers.WaitStrategy

  def run(container_config, name \\ nil) do
    case Docker.Api.create_container(container_config, name) do
      {:ok, container_id} ->
        start_and_wait(container_id, container_config)

      {:error, {:http_error, 404}} ->
        Docker.Api.pull_image(container_config.image)
        run(container_config)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def stop(container_id, options \\ []) do
    Docker.Api.stop_container(container_id, options)
  end

  defp start_and_wait(container_id, container_config) do
    :ok = Docker.Api.start_container(container_id)

    if container_config.wait_strategy do
      :ok = WaitStrategy.wait_until_container_is_ready(container_config.wait_strategy, container_id)
    end

    {:ok, container_id}
  end
end
