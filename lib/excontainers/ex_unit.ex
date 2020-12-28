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
        {:ok, container_id} = Docker.create_container(unquote(config))
        Excontainers.Agent.register_container(unquote(name), container_id)

        on_exit(fn -> Docker.stop_container(container_id, timeout_seconds: 2) end)

        :ok = Docker.start_container(container_id)
        :ok
      end
    end
  end

end
