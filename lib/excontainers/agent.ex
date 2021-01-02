defmodule Excontainers.Agent do
  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def register_container(name, pid) do
    Agent.update(__MODULE__, &Map.put(&1, name, pid))
  end

  def lookup_container(name) do
    Agent.get(__MODULE__, &Map.get(&1, name))
  end
end
