defmodule Excontainers.RedisContainerTest do
  use ExUnit.Case, async: true
  import Excontainers.ExUnit

  alias Excontainers.RedisContainer

  describe "with default configuration" do
    container(:redis, RedisContainer.new())

    test "provides a ready-to-use redis container", %{redis: redis} do
      {:ok, conn} = Redix.start_link(RedisContainer.connection_url(redis))

      assert Redix.command!(conn, ["PING"]) == "PONG"
    end
  end
end
