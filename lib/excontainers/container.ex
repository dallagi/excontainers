defmodule Excontainers.Container do
  @moduledoc """
  GenServer to interact with a docker container.
  """
  use GenServer

  @enforce_keys [:config]
  defstruct [:config, container_id: nil]

  def start_link(config, options \\ []) do
    GenServer.start_link(__MODULE__, config, options)
  end

  def stop(server, reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(server, reason, timeout)
  end

  @impl true
  def init(config) do
    {:ok, container_id} = Docker.Containers.run(config)

    {:ok, %__MODULE__{config: config, container_id: container_id}}
  end

  @impl true
  def terminate(reason, %{container_id: container_id} = _state) do
    Docker.Containers.stop(container_id)

    reason
  end

  @doc """
  Returns the configuration used to build the container.
  """
  def config(pid) do
    GenServer.call(pid, :config)
  end

  @doc """
  Returns the ID of the container on Docker.
  """
  def container_id(pid), do: GenServer.call(pid, :container_id)

  @doc """
  Returns the port on the _host machine_ that is mapped to the given port inside the _container_.
  """
  def mapped_port(pid, port), do: GenServer.call(pid, {:mapped_port, port})

  # Server

  @impl true
  def handle_call(:config, _from, state) do
    {:reply, state.config, state}
  end

  @impl true
  def handle_call(:container_id, _from, state) do
    {:reply, state.container_id, state}
  end

  @impl true
  def handle_call({:mapped_port, port}, _from, state) do
    {:ok, mapped_port} = Docker.Containers.mapped_port(state.container_id, port)
    {:reply, mapped_port, state}
  end
end
