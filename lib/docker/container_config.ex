defmodule Docker.ContainerConfig do
  @enforce_keys [:image]
  defstruct [:image, cmd: nil, exposed_ports: [], wait_strategy: nil]
end
