# Excontainers

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

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/excontainers](https://hexdocs.pm/excontainers).

## Usage

**More documentation to come as soon as this library reaches a mature-enough state**

Create a throwaway postgres container within a ExUnit test:

``` elixir
defmodule Excontainers.PostgresContainerTest do
  use ExUnit.Case, async: true
  use Excontainers.ExUnit

  alias Excontainers.{Container, PostgresContainer}

  container(:postgres, PostgresContainer.new())

  test "provides a ready-to-use postgres container" do
    {:ok, pid} = Postgrex.start_link(
      hostname: "localhost",
      port: Container.mapped_port(:postgres, 5432),
      username: "test",
      password: "test",
      database: "test"
    )

    assert %{num_rows: 1} = Postgrex.query!(pid, "SELECT 1", [])
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

* To verify: timeout in pull_image is too low?
* To verify: some tests appear to break on clean docker
* Decouple Excontainer from Docker API client (and mock interaction with docker in non-e2e tests for Excontainers)
* Add resources reaping (e.g., using testcontainers-ryuk)
* Add logs wait strategy
