defmodule Docker.CommandWaitStrategy do
  @moduledoc """
  Considers container as ready as soon as a command runs successfully inside the container.
  """
  defstruct [:command]

  @doc """
  Creates a new CommandWaitStrategy to wait until the given command executes successfully inside the container.
  """
  def new(command), do: %__MODULE__{command: command}

  defimpl Docker.WaitStrategy, for: __MODULE__ do
    def wait_until_container_is_ready(wait_strategy, id_or_name) do
      case Docker.Exec.exec_and_wait(id_or_name, wait_strategy.command) do
        {:ok, {0, _stdout}} ->
          :ok

        _ ->
          :timer.sleep(100)
          wait_until_container_is_ready(wait_strategy, id_or_name)
      end
    end
  end
end
