defmodule Environment do
  @doc """
  Returns the value of an environment variable, or a default if it is not set.
  """
  @callback get(String.t(), String.t()) :: String.t()
end
