defmodule Docker.ImagesTest do
  use ExUnit.Case, async: true

  import Support.DockerTestUtils
  alias Docker.Images

  describe "pull" do
    @image_that_no_one_should_be_using "busybox:1.24.2-uclibc"

    setup do
      remove_image(@image_that_no_one_should_be_using)
      :ok
    end

    test "pulls the image if it does not exist" do
      refute image_exists?(@image_that_no_one_should_be_using)

      :ok = Images.pull(@image_that_no_one_should_be_using)

      assert image_exists?(@image_that_no_one_should_be_using)
    end

    # This test may fail by timing out (trying to download all tags)
    # Might as well reduce the waste of time when that happens
    @tag timeout: 10_000
    test "when no tag is specified, downloads :latest image" do
      Images.pull("busybox")

      assert image_exists?("busybox:latest")
      refute image_exists?(@image_that_no_one_should_be_using)
    end

    test "returns error when image does not exist" do
      assert {:error, _} = Images.pull("unexisting-image-#{UUID.uuid4()}")
    end
  end
end
