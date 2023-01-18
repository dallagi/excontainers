defmodule Excontainers.AutoRemoveTest do
  use ExUnit.Case, async: true

  import Support.DockerTestUtils

  @sample_container Docker.Container.new("alpine", cmd: ~w(sleep infinity), auto_remove: true)

  test "when using auto_remove, the container is removed when it's stopped" do
    {:ok, container_id} = Docker.Containers.run(@sample_container)

    assert container_exists?(container_id)

    assert :ok = Docker.Containers.stop(container_id)

    refute container_exists?(container_id)
  end
end
