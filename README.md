# Excontainers

Something like [Testcontainers](https://www.testcontainers.org/), for elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `excontainers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:excontainers, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/excontainers](https://hexdocs.pm/excontainers).

## Development

### Testing

Tests require a machine with a docker daemon listening on the default unix socket `/var/run/docker.sock` and the cli docker client installed.

Run tests with

```
mix test
```

## TODO

* Add resources reaping (e.g., using ryuk ? )
