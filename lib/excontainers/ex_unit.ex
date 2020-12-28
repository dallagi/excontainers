defmodule Excontainers.ExUnit do
  defmacro __using__(_opts) do
    quote do
      import Excontainers.ExUnit

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

        on_exit(fn -> Docker.stop_container(container_id, timeout_seconds: 2) end)

        :ok = Docker.start_container(container_id)
        :ok
      end
    end
  end

end
