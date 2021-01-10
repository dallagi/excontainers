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
    {:excontainers, "~> 0.1.1", only: [:dev, :test]},
  ]
end
```

Documentation can be found at [https://hexdocs.pm/excontainers](https://hexdocs.pm/excontainers).

## Usage

#### ExUnit

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

Containers declared using the `container` helper are created for each test.
Alternatively, you can use `shared_container` to declare containers that are created once per each module and shared among its tests.

#### Direct usage

If you want to use Excontainers outside of your Exunit tests,
or if you'd like to have direct control over the lifecycle of your containers,
you can use the `Excontainers.Container` agent:

```elixir
{:ok, pid} = Container.start_link(@sample_container_config)
{:ok, container_id} = Container.start(pid)
```

### Containers

The following containers are currently provided pre-configured:

* `Excontainers.PostgresContainer`
* `Excontainers.RedisContainer`

Please open an issue if you'd like to see new ones.

#### Custom containers

Excontainers can run any container that docker can.
Custom container configurations can be built via `Excontainers.Containers.new`.

For example:

```elixir
custom_container_config = Excontainers.Containers.new(
  "alpine"
  cmd: ~w(echo hello world!),
  labels: %{"test-label-key" => "test-label-value"},
  privileged: false,
  environment: %{"SOME_KEY" => "SOME_VAL"},
  exposed_ports: [8080],
  bind_mounts: [Docker.BindMount.new("host/src", "container/dest/", "ro")],
  wait_strategy: Excontainers.CommandWaitStrategy.new(["./command/to/check/if/container/is/ready.sh"])
)
```

A builder-like API to customize container configuration is also provided:

``` elixir
alias Excontainers.Container

custom_container_config =
  Container.new("alpine", cmd: ~w("echo hello world!"), privileged: false)
  |> Container.with_environment("SOME_KEY", "SOME_VAL")
  |> Container.with_exposed_port(8080)
  |> Container.with_bind_mount("host/src", "container/dest", "ro")
```

### Resources Reaping

Under normal circumstances, Excontainers removes the containers it spawned after they are no longer useful (i.e., during the teardown phase of tests).
However, it may fail to do so when tests are interrupted abruptly, preventing ExUnit from running the necessary callbacks.

Excontainers provides a _Resources Reaper_ that makes sure containers are removed when they are no longer useful.
It runs in its own docker container, so it is not affected by crashes or problems with the tests suite.

To enable the _Resources Reaper_, simply spawn it before you run your tests, e.g., by adding this to your `tests_helper.exs`:

``` elixir
Excontainers.ResourcesReaper.start_link()
```

Containers managed via the `container` and `shared_container` helpers for ExUnit are automatically registered to the _Resources Reaper_.

When controlling the lifecycle of containers manually, containers can be registered to the _Resources Reaper_ like this:

``` elixir
Excontainers.ResourcesReaper.register({"id", my_container_id})
```

`{"id", my_container_id}` is a filter for docker resources that works on the id of the container.
Other attributes (e.g., `label`s) could also be used.

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

