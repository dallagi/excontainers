defmodule Utils.PidSerializerTest do
  defguard are_integers(a, b, c) when is_integer(a) and is_integer(b) and is_integer(c)

  use ExUnit.Case

  alias Utils.PidSerializer

  test "serializes pid to string, stripping special chars" do
    pid = pid_of(0, 250, 1)

    assert PidSerializer.serialize(pid) == "PID0-250-1"
  end

  defp pid_of(a, b, c) when are_integers(a, b, c), do: IEx.Helpers.pid(a, b, c)
end
