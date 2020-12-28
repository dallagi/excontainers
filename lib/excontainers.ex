defmodule Excontainers do
  def info(container_name) do
    container_id = Excontainers.Agent.lookup_container(container_name)
    {:ok, container_info} = Docker.inspect_container(container_id)

    container_info
  end
end
