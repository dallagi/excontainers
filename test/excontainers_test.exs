defmodule ExcontainersTest do
  use ExUnit.Case, async: true
  doctest Excontainers

  test "greets the world" do
    assert Excontainers.hello() == :world
  end
end
