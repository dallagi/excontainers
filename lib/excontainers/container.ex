defmodule Excontainers.Container do
  @moduledoc """
  Agent to interact with a docker container.
  """
  use Agent

  alias __MODULE__

  @enforce_keys [:config]
  defstruct [:config, container_id: nil]

  @doc """
  Starts the agent to interact with the container.

  This will not create the container on Docker yet.
  """
  def start_link(container_config, opts \\ []) do
    Agent.start_link(fn -> %Container{config: container_config} end, opts)
  end

  @doc """
  Creates and starts the container, and waits for it to be ready.
  """
  def start(pid) do
    {:ok, container_id} = Docker.Containers.run(config(pid))
    set_container_id(pid, container_id)
    {:ok, container_id}
  end

  @doc """
  Stops the container.
  """
  def stop(pid, opts \\ []) do
    container_id(pid)
    |> Docker.Containers.stop(opts)
  end

  @doc """
  Returns the configuration used to build the container.
  """
  def config(pid) do
    Agent.get(pid, fn container -> container.config end)
  end

  @doc """
  Returns the ID of the container on Docker.
  """
  def container_id(pid), do: Agent.get(pid, & &1.container_id)

  @doc """
  Returns the port on the _host machine_ that is mapped to the given port inside the _container_.
  """
  def mapped_port(pid, port), do: Docker.Containers.mapped_port(container_id(pid), port)

  defp set_container_id(pid, container_id) do
    Agent.update(pid, fn container ->
      %Container{container | container_id: container_id}
    end)
  end
end
