defmodule Excontainers.CephContainerTest do
  use ExUnit.Case, async: true
  import Excontainers.ExUnit

  alias Excontainers.CephContainer

  @tag timeout: 300_000

  describe "with default configuration" do
    container(:ceph, CephContainer.new())

    test "provides a ready-to-use ceph container", %{ceph: ceph} do
      url = CephContainer.connection_url(ceph)

      assert url |> String.starts_with?("http://localhost:")
    end
  end
end
