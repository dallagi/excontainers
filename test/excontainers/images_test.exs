defmodule Excontainers.ImagesTest do
  use ExUnit.Case, async: true

  import Support.DockerTestUtils

  @image_that_no_one_should_be_using "busybox:1.24.2-uclibc"

  setup do
    remove_image(@image_that_no_one_should_be_using)
    :ok
  end

  test "pulls docker image" do
    Excontainers.Images.pull(@image_that_no_one_should_be_using)

    assert image_exists?(@image_that_no_one_should_be_using)
  end

  # This test may fail by timing out (trying to download all tags)
  # Might as well reduce the waste of time when that happens
  @tag timeout: 10_000
  test "when no tag is specified, downloads :latest image" do
    Excontainers.Images.pull("busybox")

    assert image_exists?("busybox:latest")
    refute image_exists?(@image_that_no_one_should_be_using)
  end
end
