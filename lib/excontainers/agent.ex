defmodule Excontainers.Agent do
  @moduledoc """
  Keeps a registry of mapping of container names to the id of the actual containers.
  Note that container name refers to the name given in the test, not the name of the docker container.
  """

  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def register_container(name, container_id) do
    Agent.update(__MODULE__, &Map.put(&1, name, container_id))
  end

  def lookup_container(name) do
    Agent.get(__MODULE__, &Map.get(&1, name))
  end
end
