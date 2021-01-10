defmodule Excontainers.ExUnit do
  alias Excontainers.{Container, Containers, ResourcesReaper}

  defmacro container(name, config) do
    quote do
      setup do
        do_setup_container(unquote(name), unquote(config))
      end
    end
  end

  defmacro shared_container(name, config) do
    quote do
      setup_all do
        do_setup_container(unquote(name), unquote(config))
      end
    end
  end

  defmacro do_setup_container(name, config) do
    quote do
      {:ok, pid} = Container.start_link(unquote(config))
      {:ok, container_id} = pid |> Container.start()

      on_exit(fn -> Containers.stop(container_id, timeout_seconds: 2) end)
      ResourcesReaper.register({"id", container_id})

      {:ok, %{unquote(name) => pid}}
    end
  end
end
