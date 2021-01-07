# Excontainers

![CircleCI](https://img.shields.io/circleci/build/github/dallagi/excontainers/master)
![Coveralls github](https://img.shields.io/coveralls/github/dallagi/excontainers)
![Hex.pm](https://img.shields.io/hexpm/v/excontainers)

Throwaway test containers for Elixir/Erlang applications.
Heavily inspired by [Testcontainers](https://www.testcontainers.org/).

**This package is still in the early stages of development. You are encouraged to give it a try, but you should not regard it as ready for critical real world scenarios.**

## Installation

The package can be installed by adding `excontainers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:excontainers, "~> 0.1.0", only: [:dev, :test]},
  ]
end
```

Documentation can be found at [https://hexdocs.pm/excontainers](https://hexdocs.pm/excontainers).

## Usage

Create a throwaway container (in this case Redis) within a ExUnit test:

``` elixir
defmodule Excontainers.RedisContainerTest do
  use ExUnit.Case, async: true
  import Excontainers.ExUnit

  alias Excontainers.RedisContainer

  container(:redis, RedisContainer.new())

  test "provides a ready-to-use redis container", %{redis: redis} do
    {:ok, conn} = Redix.start_link(RedisContainer.connection_url(redis))

    assert Redix.command!(conn, ["PING"]) == "PONG"
  end
end
```

### Pre-configured containers

The following pre-configured containers are currently provided:

* `Excontainers.PostgresContainer`
* `Excontainers.RedisContainer`

Please open an issue if you'd like to see new ones.

### Custom containers

**Excontainers** can run any container that docker can.
Container configuration is specified via the `Docker.ContainerConfig` struct.

For example:

```elixir
custom_image = %Docker.ContainerConfig{
  image: @alpine,
  cmd: ["sleep", "3"],
  labels: %{"test-label-key" => "test-label-value"},
  privileged: false,
  environment: %{"SOME_KEY" => "SOME_VAL"},
  exposed_ports: [8080],
  bind_mounts: %Docker.VolumeBinding{container_dest: "/container/dest", host_src: "host/src", options: "ro"},
  wait_strategy: %Excontainers.CommandWaitStrategy{command: ["is_ready"]}
}
```


## Development

### Testing

Tests require a machine with a docker daemon listening on the default unix socket `/var/run/docker.sock` and the cli docker client installed.

Run tests with

```
mix test
```

## TODO

* Better separate Docker from Excontainers (i.e. take non-strictly-api-related stuff out of Docker module)
* To verify: timeout in pull_image is too low?
* To verify: apparently, API to pull images pulls ALL TAGS when no tag is given?!
* Decouple Excontainer from Docker API client (and mock interaction with docker in non-e2e tests for Excontainers)
* Add logs wait strategy
* Add TCP connection available wait strategy, and use it in tests that rely on echo http server, as sometimes it fails for not being initialized in time

