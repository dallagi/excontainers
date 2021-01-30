# Excontainers

![CircleCI](https://img.shields.io/circleci/build/github/dallagi/excontainers/master)
![Coveralls github](https://img.shields.io/coveralls/github/dallagi/excontainers)
![Hex.pm](https://img.shields.io/hexpm/v/excontainers)

Throwaway test containers for Elixir/Erlang applications.
Heavily inspired by [Testcontainers](https://www.testcontainers.org/).

#### Project status

**This package has not seen much real-world usage yet, hence it should not be considered as stable.**
You are encouraged to give it a try and report back problems you may experience.

Excontainers was started as a personal study project to practice Elixir.
The core functionalities are implemented and tested, and I plan to eventually evolve it beyond the scope of providing throwaway containers for tests.

However the development is paused, as I'm currently focused on other matters.

## Installation

The package can be installed by adding `excontainers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:excontainers, "~> 0.2.0", only: [:dev, :test]},
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

To create a container for a specific test only, use the `run_container` macro as follows:

```elixir
test "my test" do
  {:ok, redis} = run_container(RedisContainer.new())
  connection_url = RedisContainer.connection_url(redis)
  # ...
end
```

`container`, `shared_container` and `run_container` will take care of cleaning up the containers once they are no longer needed.

#### Direct usage

If you want to use Excontainers outside of your Exunit tests,
or if you'd like to have direct control over the lifecycle of your containers,
you can use the `Excontainers.Container` agent:

```elixir
{:ok, pid} = Container.start_link(@sample_container_config)
{:ok, container_id} = Container.start(pid)
:ok = Container.stop(pid)
```

### Containers

The following containers are currently provided pre-configured:

* `Excontainers.MySqlContainer`
* `Excontainers.PostgresContainer`
* `Excontainers.RedisContainer`

Please open an issue if you'd like to see new ones.

#### Custom containers

Excontainers can run any container that docker can.
Custom container configurations can be built via `Docker.Container.new`.

For example:

```elixir
custom_container_config = Docker.Container.new(
  "alpine"
  cmd: ~w(echo hello world!),
  labels: %{"test-label-key" => "test-label-value"},
  privileged: false,
  environment: %{"SOME_KEY" => "SOME_VAL"},
  exposed_ports: [8080],
  bind_mounts: [Docker.BindMount.new("host/src", "container/dest/", "ro")],
  wait_strategy: Docker.CommandWaitStrategy.new(["./command/to/check/if/container/is/ready.sh"])
)
```

A builder-like API to customize container configuration is also provided:

``` elixir
alias Docker.Container

custom_container_config =
  Container.new("alpine", cmd: ~w(echo hello world!), privileged: false)
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

Containers managed via the `container`, `shared_container` and `run_container` helpers for ExUnit are automatically registered to the _Resources Reaper_.

When controlling the lifecycle of containers manually, containers can be registered to the _Resources Reaper_ like this:

``` elixir
Excontainers.ResourcesReaper.register({"id", my_container_id})
```

`{"id", my_container_id}` is a [filter for docker resources](https://docs.docker.com/engine/reference/commandline/ps/#filtering) that works on the id of the container.
Other attributes (e.g., `label`s) could also be used.

Please note that using the id as filter for resources reaping may lead to (albeit unlikely) race conditions, where the BEAM crashes between the spawning of the container and the registration for resources reaping.
A workaround for this is to use a filter that is known before spawning the container, e.g. a label that is then applied to the container.

## Development

### Testing

Tests require a machine with a docker daemon listening on the default unix socket `/var/run/docker.sock` and the cli docker client installed.

Run tests with

```
mix test
```
