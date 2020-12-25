defmodule Utils.PidSerializer do
  @spec serialize(pid()) :: binary
  def serialize(pid) do
    pid
    |> inspect
    |> remove_chars("#<>")
    |> replace_dots_with_dashes
  end

  defp remove_chars(string, chars), do: String.replace(string, ~r/[#{chars}]/, "")

  defp replace_dots_with_dashes(string), do: String.replace(string, ~r/\./, "-")
end
