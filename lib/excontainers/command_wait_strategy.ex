defmodule Excontainers.CommandWaitStrategy do
  defstruct [:command]

  def new(command), do: %__MODULE__{command: command}

  defimpl Excontainers.WaitStrategy, for: __MODULE__ do
    def wait_until_container_is_ready(wait_strategy, id_or_name) do
      case Docker.Api.exec_and_wait(id_or_name, wait_strategy.command) do
        {:ok, {0, _stdout}} -> :ok
        _ ->
          :timer.sleep(100)
          wait_until_container_is_ready(wait_strategy, id_or_name)
      end
    end
  end
end
