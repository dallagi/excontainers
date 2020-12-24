defmodule DockerTest do
  use ExUnit.Case

  test "xxx" do
    {:ok, response} = Docker.xxx()

    assert response.status == 200
  end
end
