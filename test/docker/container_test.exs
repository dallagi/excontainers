defmodule Docker.ContainerTest do
  use ExUnit.Case, async: true

  import Support.DockerTestUtils

  describe "mapped_port/2" do
    test "gets the host port corresponding to a mapped port in the container" do
      container_id =
        run_a_container(
          "hashicorp/http-echo:0.2.3",
          ["-listen=:8080", ~s(-text="hello world")],
          "8080"
        )

      port = Docker.Container.mapped_port(container_id, 8080)
      {:ok, response} = Tesla.get("http://localhost:#{port}/")

      assert is_integer(port)
      assert response.body =~ "hello world"
    end
  end
end
