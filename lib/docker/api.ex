defmodule Docker.Api do
  alias __MODULE__
  alias Docker.Container

  defdelegate ping(), to: Api.Operation, as: :ping

  defdelegate inspect_container(container_id), to: Api.Container, as: :inspect

  defdelegate create_container(container_config, name \\ nil), to: Api.Container, as: :create

  defdelegate start_container(container_id), to: Api.Container, as: :start

  defdelegate stop_container(container_id, options \\ []), to: Api.Container, as: :stop

  defdelegate start_exec(exec_id), to: Api.Exec, as: :start

  defdelegate create_exec(container_id, command), to: Api.Exec, as: :create

  defdelegate inspect_exec(exec_id), to: Api.Exec, as: :inspect



  # Part still to extract from Docker.Api

  defdelegate exec_and_wait(container_id, command, options \\ []), to: Docker.Exec, as: :exec_and_wait

  defdelegate run_container(container_config, name \\ nil), to: Container, as: :run

  def pull_image(name) do
    image_name =
      name
      |> with_latest_tag_by_default()

    Docker.Api.Image.pull(image_name)
  end

  defp with_latest_tag_by_default(name) do
    case String.contains?(name, ":") do
      true -> name
      false -> "#{name}:latest"
    end
  end
end
