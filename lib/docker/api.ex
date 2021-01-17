defmodule Docker.Api do
  @moduledoc false
  alias __MODULE__

  defdelegate ping(), to: Api.Operation, as: :ping

  defdelegate inspect_container(container_id), to: Api.Containers, as: :inspect

  defdelegate create_container(container_config, name \\ nil), to: Api.Containers, as: :create

  defdelegate start_container(container_id), to: Api.Containers, as: :start

  defdelegate stop_container(container_id, options \\ []), to: Api.Containers, as: :stop

  defdelegate start_exec(exec_id), to: Api.Exec, as: :start

  defdelegate create_exec(container_id, command), to: Api.Exec, as: :create

  defdelegate inspect_exec(exec_id), to: Api.Exec, as: :inspect
end
