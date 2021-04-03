defmodule Excontainers.RedisContainer do
  @moduledoc """
  Functions to build and interact with Redis containers.
  """

  alias Excontainers.Container
  alias Docker.CommandWaitStrategy

  @redis_port 6379
  @wait_strategy CommandWaitStrategy.new(["redis-cli", "PING"])

  @doc """
  Creates a Redis container.

  Runs Redis 6.0 by default, but a custom image can also be set.
  """
  def new(image \\ "redis:6.0-alpine", _opts \\ []) do
    Docker.Container.new(
      image,
      exposed_ports: [@redis_port],
      environment: %{},
      wait_strategy: @wait_strategy
    )
  end

  @doc """
  Returns the port on the _host machine_ where the Redis container is listening.
  """
  def port(pid), do: with({:ok, port} <- Container.mapped_port(pid, @redis_port), do: port)

  @doc """
  Returns the connection url to connect to Redis from the _host machine_.
  """
  def connection_url(pid), do: "redis://localhost:#{port(pid)}/"
end
