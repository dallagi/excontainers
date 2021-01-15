defmodule Excontainers.MySqlContainer do
  alias Excontainers.Container
  alias Docker.CommandWaitStrategy

  @mysql_port 3306

  @doc """
  Creates a MySql container.

  Runs MySql 8.0 by default, but a custom image can also be set.

  ## Options

  - `username` sets the username for the user
  - `password` sets the password for the user
  - `database` sets the name of the database
  """
  def new(image \\ "mysql:8.0", opts \\ []) do
    username = Keyword.get(opts, :username, "test")
    password = Keyword.get(opts, :password, "test")

    Docker.Container.new(
      image,
      exposed_ports: [@mysql_port],
      environment: %{
        MYSQL_USER: username,
        MYSQL_PASSWORD: password,
        MYSQL_DATABASE: Keyword.get(opts, :database, "test"),
        MYSQL_RANDOM_ROOT_PASSWORD: "yes"
      },
      wait_strategy: wait_strategy(username, password)
    )
  end

  @doc """
  Returns the port on the _host machine_ where the MySql container is listening.
  """
  def port(pid), do: Container.mapped_port(pid, @mysql_port)

  @doc """
  Returns the connection parameters to connect to the database from the _host machine_.
  """
  def connection_parameters(pid) do
    config = Container.config(pid)

    [
      hostname: "localhost",
      port: port(pid),
      username: config.environment[:MYSQL_USER],
      password: config.environment[:MYSQL_PASSWORD],
      database: config.environment[:MYSQL_DATABASE]
    ]
  end

  defp wait_strategy(username, password) do
    CommandWaitStrategy.new([
      "sh",
      "-c",
      "mysqladmin ping --user='#{username}' --password='#{password}' -h localhost | grep 'mysqld is alive'"
    ])
  end
end
