defmodule Docker.LogWaitStrategy do
  @moduledoc """
  Considers container as ready as soon as a command runs successfully inside the container.
  """
  defstruct [:log_statement]

  @doc """
  Creates a new CommandWaitStrategy to wait until the given command executes successfully inside the container.
  """
  def new(log_statement), do: %__MODULE__{log_statement: log_statement}
end

defimpl Docker.WaitStrategy, for: Docker.LogWaitStrategy do
  def wait_until_container_is_ready(wait_strategy, id_or_name) do
    try do
      case Docker.Api.Exec.stdout_logs(id_or_name) do
        {:ok, stdout} ->
          if String.contains?(stdout, wait_strategy.log_statement) do
            :ok
          else
            wait_until_container_is_ready(wait_strategy, id_or_name)
          end

        _ ->
          :timer.sleep(100)
          wait_until_container_is_ready(wait_strategy, id_or_name)
      end
    rescue
      _ in RuntimeError ->
        # some logging must be done here
        {:error, :suppressed_error}
    end
  end
end
