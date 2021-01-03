defmodule Docker.ContainerConfig do
  @enforce_keys [:image]
  defstruct [:image, cmd: nil, environment: %{}, exposed_ports: [], wait_strategy: nil, privileged: false]
end
