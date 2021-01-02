defmodule Excontainers.Container do
  @moduledoc """
  GenServer to interact with a docker container.
  """
  use Agent

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
    |> Containers.stop()
  end

  def config(name) when is_atom(name), do: config(Excontainers.Agent.lookup_container(name))

  def config(pid) do
    Agent.get(pid, fn container -> container.config end)
  end

  def container_id(name) when is_atom(name), do: container_id(Excontainers.Agent.lookup_container(name))
  def container_id(pid), do: Agent.get(pid, & &1.container_id)

  def mapped_port(name) when is_atom(name), do: mapped_port(Excontainers.Agent.lookup_container(name))
  def mapped_port(pid, port), do: Containers.mapped_port(container_id(pid), port)

  defp set_container_id(pid, container_id) do
    Agent.update(pid, fn container ->
      %Container{container | container_id: container_id}
    end)
  end
end
