defmodule Docker.Exec do
  alias Docker.Client

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
    {:ok, exec_id} = create_exec(container_id, command)
    :ok = start_exec(exec_id)

    {:ok, exec_id}
  end

  def inspect_exec(exec_id) do
    case Client.get("/exec/#{exec_id}/json") do
      {:ok, %{status: 200, body: body}} -> {:ok, parse_inspect_result(body)}
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end

  defp create_exec(container_id, command) do
    data = %{"Cmd" => command}

    case Client.post("/containers/#{container_id}/exec", data) do
      {:ok, %{status: 201, body: body}} -> {:ok, body["Id"]}
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end

  defp start_exec(exec_id) do
    case Client.post("/exec/#{exec_id}/start", %{}) do
      {:ok, %{status: 200}} -> :ok
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end

  defp parse_inspect_result(json) do
    %ExecStatus{running: json["Running"], exit_code: json["ExitCode"]}
  end

  defp wait_for_exec_result(exec_id, timeout_ms, started_at \\ monotonic_time()) do
    case Docker.Exec.inspect_exec(exec_id) do
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
