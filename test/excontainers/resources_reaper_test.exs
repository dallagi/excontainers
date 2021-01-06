defmodule Excontainers.ResourcesReaperTest do
  use ExUnit.Case, async: true

  alias Excontainers.{Containers, ResourcesReaper}
  import Support.DockerTestUtils

  @unique_name __MODULE__
  @sample_container Containers.new("alpine", cmd: ~w(sleep infinity))
  @expected_timeout_seconds 10

  test "when it terminates, reaps all registered resources after a timeout" do
    ResourcesReaper.start_link(@unique_name)
    {:ok, container_id} = Containers.start(@sample_container)
    ResourcesReaper.register(@unique_name, {"id", container_id})
    assert container_exists?(container_id)

    Process.exit(Process.whereis(@unique_name), :normal)
    wait_for_timeout()

    refute container_exists?(container_id)
  end

  defp wait_for_timeout do
    time_to_wait_ms = (@expected_timeout_seconds + 1) * 1000

    :timer.sleep(time_to_wait_ms)
  end

  defp container_exists?(container_id) do
    {all_containers, _exit_code = 0} = System.cmd("docker", ~w(ps -a))
    all_containers =~ short_id(container_id)
  end
end
