defmodule Docker.Container do
  @enforce_keys [:image]
  defstruct [:image, :name, :cmd]
end
