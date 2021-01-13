defmodule Excontainers.PostgresContainer do
  alias Excontainers.Container
  alias Docker.CommandWaitStrategy

  @postgres_port 5432
  @wait_strategy CommandWaitStrategy.new(["pg_isready", "-U", "test", "-d", "test", "-h", "localhost"])

  def new(image \\ "postgres:13.1", opts \\ []) do
    Docker.Container.new(
      image,
      exposed_ports: [@postgres_port],
      environment: %{
        POSTGRES_USER: Keyword.get(opts, :username, "test"),
        POSTGRES_PASSWORD: Keyword.get(opts, :password, "test"),
        POSTGRES_DB: Keyword.get(opts, :database, "test")
      },
      wait_strategy: @wait_strategy
    )
  end

  def port(pid), do: Container.mapped_port(pid, @postgres_port)

  def connection_parameters(pid) do
    config = Container.config(pid)

    [
      hostname: "localhost",
      port: port(pid),
      username: config.environment[:POSTGRES_USER],
      password: config.environment[:POSTGRES_PASSWORD],
      database: config.environment[:POSTGRES_DB]
    ]
  end
end
