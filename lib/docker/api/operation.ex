defmodule Docker.Api.Operation do
  @doc false

  alias Docker.Api.Client

  def ping() do
    case Client.get("/_ping") do
      {:ok, %{status: 200}} -> :ok
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end
end
