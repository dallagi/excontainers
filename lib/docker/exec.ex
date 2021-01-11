defmodule Docker.Exec do

  defmodule ExecStatus do
    defstruct [:running, :exit_code]
  end

  def exec_and_wait(container_id, command, options \\ []) do
    timeout_ms = options[:timeout_ms]

    {:ok, exec_id} = exec(container_id, command)

    case wait_for_exec_result(exec_id, timeout_ms) do
      {:ok, exec_info} -> {:ok, {exec_info.exit_code, ""}}
      {:error, :timeout} -> {:error, :timeout}
    end
  end

  def exec(container_id, command) do
    {:ok, exec_id} = Docker.Api.create_exec(container_id, command)
    :ok = Docker.Api.start_exec(exec_id)

    {:ok, exec_id}
  end

  defp wait_for_exec_result(exec_id, timeout_ms, started_at \\ monotonic_time()) do
    case Docker.Api.inspect_exec(exec_id) do
      {:ok, %ExecStatus{running: true}} -> do_wait_unless_timed_out(exec_id, timeout_ms, started_at)
      {:ok, finished_exec_status} -> {:ok, finished_exec_status}
    end
  end

  defp do_wait_unless_timed_out(exec_id, timeout_ms, started_at) do
    if out_of_time(started_at, timeout_ms) do
      {:error, :timeout}
    else
      :timer.sleep(100)
      wait_for_exec_result(exec_id, timeout_ms, started_at)
    end
  end

  defp monotonic_time, do: System.monotonic_time(:millisecond)

  defp out_of_time(started_at, timeout_ms), do: monotonic_time() - started_at > timeout_ms
end
