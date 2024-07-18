defmodule Docker.ContainerState do
  @moduledoc false
  defstruct [:id, :status, :mapped_ports]

  alias __MODULE__

  defmodule Status do
    @moduledoc false

    @allowed_statuses ~w(created running paused restarting removing exited dead)
    @type state :: :created | :running | :paused | :restarting | :removing | :exited | :dead

    defguardp is_allowed(status) when status in @allowed_statuses

    defstruct [:state, :running]

    def parse_status(status_as_string) when is_allowed(status_as_string), do: String.to_atom(status_as_string)
    def parse_status(_), do: nil
  end

  def parse_docker_response(json_info) do
    %ContainerState{
      id: json_info["Id"],
      status: %ContainerState.Status{
        state: ContainerState.Status.parse_status(json_info["State"]["Status"]),
        running: json_info["State"]["Running"]
      },
      mapped_ports: port_mapping(json_info["NetworkSettings"]["Ports"])
    }
  end

  defp port_mapping(json_ports) do
    json_ports
    |> Enum.map(fn {cont, host} -> {cont, host_port(host)} end)
    |> Enum.into(%{})
  end

  defp host_port(nil), do: nil

  defp host_port([]), do: nil

  defp host_port(ports) do
    ports
    |> Enum.at(0)
    |> Map.get("HostPort")
  end
end
