defmodule Docker.Exec do
  alias Docker.Client

  defmodule ExecStatus do
    defstruct [:running, :exit_code]
  end

  def exec_and_wait(container_id, command) do
    {:ok, exec_id} = create_exec(container_id, command)
    :ok = start_exec(exec_id)
    {:ok, exec} = inspect_exec(exec_id)

    {:ok, {exec.exit_code, ""}}
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

  defp inspect_exec(exec_id) do
    case Client.get("/exec/#{exec_id}/json") do
      {:ok, %{status: 200, body: body}} -> {:ok, parse_inspect_result(body)}
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end

  defp parse_inspect_result(json) do
    %ExecStatus{running: json["Running"], exit_code: json["ExitCode"]}
  end
end
