defmodule Excontainers.MixProject do
  use Mix.Project

  @source_url "https://github.com/dallagi/excontainers"
  @version "0.3.0"

  def project do
    [
      app: :excontainers,
      description: "Throwaway containers for your tests",
      source_url: @source_url,
      version: @version,
      elixir: "~> 1.13.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      package: [
        links: %{"GitHub" => @source_url},
        licenses: ["GPL-3.0-or-later"]
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      docs: [
        main: "readme",
        extras: ["README.md", "LICENSE"],
        source_ref: "v#{@version}",
        source_url: @source_url
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}

      {:hackney, "~> 1.18"},
      {:jason, "~> 1.3"},
      {:tesla, "~> 1.4.0"},
      {:gestalt, "~> 1.0"},
      {:excoveralls, "~> 0.14", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:elixir_uuid, "~> 1.2", only: [:dev, :test]},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false},
      {:myxql, "~> 0.5.0", only: [:dev, :test]},
      {:postgrex, "~> 0.9", only: [:dev, :test]},
      {:redix, "~> 1.1", only: [:dev, :test]}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
