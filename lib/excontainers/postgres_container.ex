defmodule Excontainers.PostgresContainer do
  alias Excontainers.{Container, CommandWaitStrategy}

  @exposed_ports [5432]
  @environment %{POSTGRES_USER: "test", POSTGRES_PASSWORD: "test", POSTGRES_DB: "test"}
  @wait_strategy CommandWaitStrategy.new(["pg_isready", "-U", "test", "-d", "test", "-h", "localhost"])

  def new(image \\ "postgres:13.1", opts \\ []) do
    Container.new(
      image,
      exposed_ports: @exposed_ports,
      environment: @environment,
      wait_strategy: @wait_strategy
    )
  end
end
