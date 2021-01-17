defmodule Docker.Api.Exec do
  @moduledoc false

  alias Docker.Api.Client

  def inspect(exec_id) do
    case Client.get("/exec/#{exec_id}/json") do
      {:ok, %{status: 200, body: body}} -> {:ok, parse_inspect_result(body)}
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end

  def create(container_id, command) do
    data = %{"Cmd" => command}

    case Client.post("/containers/#{container_id}/exec", data) do
      {:ok, %{status: 201, body: body}} -> {:ok, body["Id"]}
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end

  def start(exec_id) do
    case Client.post("/exec/#{exec_id}/start", %{}) do
      {:ok, %{status: 200}} -> :ok
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end

  defp parse_inspect_result(json) do
    %Docker.Exec.ExecStatus{running: json["Running"], exit_code: json["ExitCode"]}
  end
end
