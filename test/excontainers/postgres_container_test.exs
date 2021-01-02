defmodule Excontainers.PostgresContainerTest do
  use ExUnit.Case, async: true
  use Excontainers.ExUnit

  alias Excontainers.{Containers, PostgresContainer}

  describe "with default configuration" do
    container(:postgres, PostgresContainer.new())

    test "provides a ready-to-use postgres container" do
      {:ok, pid} = Postgrex.start_link(
        hostname: "localhost",
        port: Containers.mapped_port(:postgres, 5432),
        username: "test",
        password: "test",
        database: "test"
      )

      assert %{num_rows: 1} = Postgrex.query!(pid, "SELECT 1", [])
    end
  end
end
