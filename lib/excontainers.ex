defmodule Excontainers do
  @moduledoc """
  Documentation for `Excontainers`.
  """

  defmacro __using__(_opts) do
    quote do
      import Excontainers

      setup do
        Agent.start_link(fn -> %{} end, name: Excontainers.Agent)
        :ok
      end
    end
  end

  defmacro container(name, config) do
    quote do
      setup do
        {:ok, container_id} = Docker.create_container(unquote(config))
        Agent.update(Excontainers.Agent, &Map.put(&1, unquote(name), container_id))
        on_exit(fn -> Docker.stop_container(container_id) end)
        :ok = Docker.start_container(container_id)

        :ok
      end
    end
  end

  def info(container_name) do
    container_id = Agent.get(Excontainers.Agent, &Map.get(&1, container_name))
    {:ok, container_info} = Docker.inspect_container(container_id)

    container_info
  end
end
