defmodule Excontainers.ExUnit do
  alias Excontainers.{Container, Containers}

  defmacro container(name, config) do
    quote do
      setup do
        {:ok, pid} = Container.start_link(unquote(config))
        {:ok, container_id} = pid |> Container.start()

        on_exit(fn -> Containers.stop(container_id, timeout_seconds: 2) end)

        {:ok, %{unquote(name) => pid}}
      end
    end
  end

end
