defmodule DockerTest do
  use ExUnit.Case

  setup do
    Mox.stub_with(MockEnvironment, Support.StubEnvironment)
    :ok
  end

  test "xxx" do
    {:ok, response} = Docker.xxx()

    assert response.status == 200
  end
end
