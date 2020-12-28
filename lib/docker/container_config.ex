defmodule Docker.ContainerConfig do
  @enforce_keys [:image]
  defstruct [:image, :cmd, :exposed_ports]
end
