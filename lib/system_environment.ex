defmodule SystemEnvironment do
  @behaviour Environment

  @impl Environment
  def get(key, default \\ nil), do: System.get_env(key, default)
end
