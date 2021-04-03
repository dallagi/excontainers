defmodule Excontainers.ExUnit do
  @moduledoc """
  Convenient macros to run containers within ExUnit tests.
  """

  alias Excontainers.{Container, ResourcesReaper}

  @doc """
  Sets a container to be created anew for each test in the module.

  It also sets up the ExUnit callback to remove the container after the test has finished.
  """
  defmacro container(name, config) do
    quote do
      setup do
        {:ok, pid} = run_container(unquote(config))

        {:ok, %{unquote(name) => pid}}
      end
    end
  end

  @doc """
  Sets a container to be created at the beginning of the test module, and shared among all the tests.

  It also sets up the ExUnit callback to remove the container after all the test in the module have finished.
  """
  defmacro shared_container(name, config) do
    quote do
      setup_all do
        {:ok, pid} = run_container(unquote(config))

        {:ok, %{unquote(name) => pid}}
      end
    end
  end

  @doc """
  Runs a container for a single ExUnit test.

  It also sets up the ExUnit callback to remove the container after the test finishes.
  """
  defmacro run_container(config) do
    quote do
      {:ok, pid} = Container.start_link(unquote(config))
      container_id = Container.container_id(pid)

      on_exit(fn -> Docker.Containers.stop(container_id, timeout_seconds: 2) end)
      ResourcesReaper.register({"id", container_id})

      {:ok, pid}
    end
  end
end
