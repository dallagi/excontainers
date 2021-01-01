defmodule Excontainers.ExUnit do
  defmacro __using__(_opts) do
    quote do
      import Excontainers.ExUnit

      setup do
        Excontainers.Agent.start_link()
        :ok
      end
    end
  end

  defmacro container(name, config) do
    quote do
      setup do
        {:ok, container_id} = Excontainers.Container.start(unquote(config))
        Excontainers.Agent.register_container(unquote(name), container_id)

        on_exit(fn -> Excontainers.Container.stop(container_id, timeout_seconds: 2) end)

        :ok
      end
    end
  end
end
