defmodule Excontainers.ExUnit do
  alias Excontainers.{Container, ResourcesReaper}

  defmacro container(name, config) do
    quote do
      setup do
        {:ok, pid} = run_container(unquote(config))

        {:ok, %{unquote(name) => pid}}
      end
    end
  end

  defmacro shared_container(name, config) do
    quote do
      setup_all do
        {:ok, pid} = run_container(unquote(config))

        {:ok, %{unquote(name) => pid}}
      end
    end
  end

  defmacro run_container(config) do
    quote do
      {:ok, pid} = Container.start_link(unquote(config))
      {:ok, container_id} = pid |> Container.start()

      on_exit(fn -> Docker.Containers.stop(container_id, timeout_seconds: 2) end)
      ResourcesReaper.register({"id", container_id})

      {:ok, pid}
    end
  end
end
