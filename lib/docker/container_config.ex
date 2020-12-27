defmodule Docker.ContainerConfig do
  @enforce_keys [:image]
  defstruct [:image, :cmd]
end
