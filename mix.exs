defmodule Excontainers.MixProject do
  use Mix.Project

  def project do
    [
      app: :excontainers,
      description: "Throwaway containers for your tests",
      source_url: "https://github.com/dallagi/excontainers",
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      package: [
        links: %{"GitHub" => "https://github.com/dallagi/excontainers"},
        licenses: ["GPL-3.0-or-later"]
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

      {:hackney, "~> 1.16.0"},
      {:jason, ">= 1.0.0"},
      {:tesla, "~> 1.4.0"},
      {:gestalt, "~> 1.0"},

      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:elixir_uuid, "~> 1.2", only: [:dev, :test]},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},

      {:postgrex, "~> 0.15", only: [:dev, :test]},
      {:redix, ">= 0.0.0", only: [:dev, :test]},
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
