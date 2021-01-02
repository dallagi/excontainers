defmodule Excontainers.ExUnit.SimpleTest do
  use ExUnit.Case, async: true

  import Excontainers.ExUnit
  alias Excontainers.{Container, Containers}

  container(:alpine, Containers.new("alpine:20201218", cmd: ["sleep", "infinity"]))

  test "container is ran during tests", %{alpine: alpine} do
    container_id = Container.container_id(alpine)

    {running_containers_output, _exit_code = 0} = System.cmd("docker", ["ps"])
    assert running_containers_output =~ String.slice(container_id, 1..11)
  end
end
