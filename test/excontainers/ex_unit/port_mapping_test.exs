defmodule Excontainers.ExUnit.PortMappingTest do
  use ExUnit.Case, async: true
  use Excontainers.ExUnit
  alias Excontainers.{Container, Containers}

  @http_echo_container Containers.new(
                         "hashicorp/http-echo:0.2.3",
                         cmd: ["-listen=:8080", ~s(-text="hello world")],
                         exposed_ports: [8080]
                       )

  container(:http_echo, @http_echo_container)

  test "maps container ports to random ports on the host" do
    port = Container.mapped_port(:http_echo, 8080)

    {:ok, response} = Tesla.get("http://localhost:#{port}/")

    assert response.body =~ "hello world"
  end
end
