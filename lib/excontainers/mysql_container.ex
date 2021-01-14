defmodule Excontainers.MySqlContainer do
  alias Excontainers.Container
  alias Docker.CommandWaitStrategy

  @mysql_port 3306

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

  def port(pid), do: Container.mapped_port(pid, @mysql_port)

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
    # CommandWaitStrategy.new(["mysqladmin", "ping", "--user='#{username}'", "--password='#{password}'", "-h", "localhost"])
    CommandWaitStrategy.new(["sh", "-c", "mysqladmin ping --user='#{username}' --password='#{password}' -h localhost | grep 'mysqld is alive'"])
  end
end
