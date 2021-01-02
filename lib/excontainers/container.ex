defmodule Excontainers.Container do
  @moduledoc """
  GenServer to interact with a docker container.
  """
  # TODO: replace Excontianers.Container with this module
  use Agent
  # use GenServer

  alias __MODULE__
  alias Excontainers.Containers

  @enforce_keys [:config]
  defstruct [:config, container_id: nil]

  def start_link(container_config) do
    Agent.start_link(fn -> %Container{config: container_config} end)
  end

  def start(pid) do
    {:ok, container_id} = Containers.start(config(pid))
    set_container_id(pid, container_id)
    {:ok, container_id}
  end

  def stop(pid) do
    container_id(pid)
    |> Containers.stop
  end

  def config(pid) do
    Agent.get(pid, fn container -> container.config end)
  end

  def container_id(pid), do: Agent.get(pid, &(&1.container_id))

  defp set_container_id(pid, container_id) do
    Agent.update(pid, fn container ->
      %Container{ container | container_id: container_id }
    end)
  end
end
