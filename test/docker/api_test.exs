defmodule Docker.ApiTest do
  use ExUnit.Case, async: true

  alias Docker.Api

  describe "ping/0" do
    test "returns :ok when communication with docker is successful" do
      assert Api.ping() == :ok
    end

    test "returns error when communication with docker fails" do
      :ok = Gestalt.replace_env("DOCKER_HOST", "tcp://invalid-docker-host:1234", self())

      assert {:error, _} = Api.ping()
    end
  end
end
