defmodule Docker do
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

  def create_container(container_config, name \\ nil), do: Container.create(container_config, name)

  def start_container(container_id), do: Container.start(container_id)

  def stop_container(container_id, options \\ [timeout_seconds: 10]), do: Container.stop(container_id, options)

  def exec_and_wait(container_id, command), do: Docker.Exec.exec_and_wait(container_id, command)

  def pull_image(name) do
    case Tesla.post(Client.plain_text(), "/images/create", "", query: %{fromImage: name}) do
      {:ok, %{status: 200}} -> :ok
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end
end
