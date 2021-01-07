# Excontainers

![CircleCI](https://img.shields.io/circleci/build/github/dallagi/excontainers/master)
![Coveralls github](https://img.shields.io/coveralls/github/dallagi/excontainers)
![Hex.pm](https://img.shields.io/hexpm/v/excontainers)

Throwaway test containers for Elixir/Erlang applications.
Heavily inspired by [Testcontainers](https://www.testcontainers.org/).

**This library is still under development and it is not to be considered ready for real-world use.**

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

**More documentation to come as soon as this library reaches a mature-enough state**

Create a throwaway redis container within a ExUnit test:

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
* To verify: some tests appear to break on clean docker
* To verify: apparently, API to pull images pulls ALL TAGS when no tag is given?!
* Decouple Excontainer from Docker API client (and mock interaction with docker in non-e2e tests for Excontainers)
* Add resources reaping (e.g., using testcontainers-ryuk)
* Add logs wait strategy
* Add TCP connection available wait strategy, and use it in tests that rely on echo http server, as sometimes it fails for not being initialized in time
* Setup CI (use circle instead of github? )

