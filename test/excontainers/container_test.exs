defmodule Excontainers.ContainerTest do
  use ExUnit.Case, async: true

  alias Excontainers.Container

  test "new/2 creates container with given image" do
    assert Container.new("some-image") == %Docker.ContainerConfig{image: "some-image"}
  end
end
