defmodule Excontainers.ResourcesReaperTest do
  use ExUnit.Case, async: true

  alias Excontainers.ResourcesReaper
  import Support.DockerTestUtils

  @sample_container Docker.Container.new("alpine", cmd: ~w(sleep infinity), auto_remove: false)
  @expected_timeout_seconds 15

  test "when it terminates, reaps all registered resources after a timeout" do
    {:ok, resources_reaper_pid} = ResourcesReaper.start_link()
    {:ok, container_id} = Docker.Containers.run(@sample_container)

    resources_reaper_pid
    |> ResourcesReaper.register({"id", container_id})

    assert container_exists?(container_id)

    resources_reaper_pid
    |> Process.exit(:normal)

    wait_for_timeout()

    refute container_exists?(container_id)
  end

  defp wait_for_timeout do
    time_to_wait_ms = (@expected_timeout_seconds + 1) * 1000

    :timer.sleep(time_to_wait_ms)
  end
end
