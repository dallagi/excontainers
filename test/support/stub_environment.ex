defmodule Support.StubEnvironment do
  @behaviour Environment

  @impl Environment
  def get(_, default), do: default
end
