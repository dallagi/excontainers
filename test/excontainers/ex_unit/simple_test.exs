defmodule Excontainers.ExUnit.SimpleTest do
  use ExUnit.Case, async: true

  import Excontainers.ExUnit
  import Support.DockerTestUtils
  alias Excontainers.{Container, Containers}

  container(:alpine, Containers.new("alpine:20201218", cmd: ["sleep", "infinity"]))
  shared_container(:shared_alpine, Containers.new("alpine:20201218", cmd: ["sleep", "infinity"]))

  test "container is ran during tests", %{alpine: alpine} do
    container_id = Container.container_id(alpine)

    assert container_running?(container_id)
  end

  test "shared_container is ran during tests", %{shared_alpine: shared_alpine} do
    container_id = Container.container_id(shared_alpine)

    assert container_running?(container_id)
  end
end
