defmodule Excontainers.ExUnit do
  alias Excontainers.{Container, Containers}

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
        {:ok, container_pid} = Container.start_link(unquote(config))
        {:ok, container_id} = container_pid |> Container.start

        Excontainers.Agent.register_container(unquote(name), container_pid)

        on_exit(fn -> Containers.stop(container_id, timeout_seconds: 2) end)

        :ok
      end
    end
  end
end
