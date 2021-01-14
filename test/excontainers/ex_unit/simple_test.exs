defmodule Excontainers.ExUnit.SimpleTest do
  use ExUnit.Case, async: true

  import Excontainers.ExUnit
  import Support.DockerTestUtils
  alias Excontainers.Container

  @container Docker.Container.new("alpine:20201218", cmd: ["sleep", "infinity"])

  container(:alpine, @container)
  shared_container(:shared_alpine, @container)

  test "container is ran during tests", %{alpine: alpine} do
    container_id = Container.container_id(alpine)

    assert container_running?(container_id)
  end

  test "shared_container is ran during tests", %{shared_alpine: shared_alpine} do
    container_id = Container.container_id(shared_alpine)

    assert container_running?(container_id)
  end

  test "run_container runs container for single test" do
    {:ok, pid} = run_container(@container)
    container_id = Container.container_id(pid)

    assert container_running?(container_id)
  end
end
