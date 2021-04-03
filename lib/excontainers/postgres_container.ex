defmodule Excontainers.PostgresContainer do
  @moduledoc """
  Functions to build and interact with PostgreSql containers.
  """

  alias Excontainers.Container
  alias Docker.CommandWaitStrategy

  @postgres_port 5432
  @wait_strategy CommandWaitStrategy.new(["pg_isready", "-U", "test", "-d", "test", "-h", "localhost"])

  @doc """
  Builds a PostgreSql container.

  Uses PostgreSql 13.1 by default, but a custom image can also be set.

  ## Options

  - `username` sets the username for the user
  - `password` sets the password for the user
  - `database` sets the name of the database
  """
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

  @doc """
  Returns the port on the _host machine_ where the MySql container is listening.
  """
  def port(pid), do: with({:ok, port} <- Container.mapped_port(pid, @postgres_port), do: port)

  @doc """
  Returns the connection parameters to connect to the database from the _host machine_.
  """
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
