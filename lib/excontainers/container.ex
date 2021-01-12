defmodule Excontainers.Container do
  @moduledoc """
  Agent to interact with a docker container.
  """
  use Agent

  alias __MODULE__
  alias Excontainers.Containers

  @enforce_keys [:config]
  defstruct [:config, container_id: nil]

  def start_link(container_config, opts \\ []) do
    Agent.start_link(fn -> %Container{config: container_config} end, opts)
  end

  def start(pid) do
    {:ok, container_id} = Docker.Api.run_container(config(pid))
    set_container_id(pid, container_id)
    {:ok, container_id}
  end

  def stop(pid, opts \\ []) do
    container_id(pid)
    |> Containers.stop(opts)
  end

  def config(pid) do
    Agent.get(pid, fn container -> container.config end)
  end

  def container_id(pid), do: Agent.get(pid, & &1.container_id)

  def mapped_port(pid, port), do: Docker.Container.mapped_port(container_id(pid), port)

  defp set_container_id(pid, container_id) do
    Agent.update(pid, fn container ->
      %Container{container | container_id: container_id}
    end)
  end
end
