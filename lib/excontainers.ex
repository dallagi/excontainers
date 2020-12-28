defmodule Excontainers do
  @moduledoc """
  Documentation for `Excontainers`.
  """

  def info(container_name) do
    container_id = Agent.get(Excontainers.Agent, &Map.get(&1, container_name))
    {:ok, container_info} = Docker.inspect_container(container_id)

    container_info
  end
end
