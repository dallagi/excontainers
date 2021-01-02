defmodule Excontainers.ExUnit.SimpleTest do
  use ExUnit.Case, async: true
  use Excontainers.ExUnit

  alias Excontainers.Containers

  container(:alpine, Containers.new("alpine:20201218", cmd: ["sleep", "infinity"]))

  test "container is ran during tests" do
    container_id = Containers.info(:alpine).id

    {running_containers_output, _exit_code = 0} = System.cmd("docker", ["ps"])
    assert running_containers_output =~ String.slice(container_id, 1..11)
  end
end
