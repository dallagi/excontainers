defmodule Excontainers.SimpleTest do
  use ExUnit.Case, async: true
  use Excontainers

  setup do
    Mox.stub_with(MockEnvironment, Support.StubEnvironment)
    :ok
  end

  container(:alpine, %Docker.ContainerConfig{image: "alpine:20201218", cmd: ["sleep", "infinity"]})

  test "container is ran during tests" do
    container_id = Excontainers.info(:alpine).id

    {running_containers_output, _exit_code = 0} = System.cmd("docker", ["ps"])
    assert running_containers_output =~ String.slice(container_id, 1..11)
  end
end
