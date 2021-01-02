defmodule Docker.Api do
  alias Docker.{Client, Container, ContainerState}

  def ping() do
    case Client.get("/_ping") do
      {:ok, %{status: 200}} -> :ok
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end

  def inspect_container(container_id) do
    case Client.get("/containers/#{container_id}/json") do
      {:ok, %{status: 200, body: body}} -> {:ok, ContainerState.parse_docker_response(body)}
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end

  defdelegate create_container(container_config, name \\ nil), to: Container, as: :create

  defdelegate start_container(container_id), to: Container, as: :start

  defdelegate stop_container(container_id, options \\ []), to: Container, as: :stop

  defdelegate exec_and_wait(container_id, command), to: Docker.Exec, as: :exec_and_wait

  def pull_image(name) do
    case Tesla.post(Client.plain_text(), "/images/create", "", query: %{fromImage: name}) do
      {:ok, %{status: 200}} -> :ok
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end
end
