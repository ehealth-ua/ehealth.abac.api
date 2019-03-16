defmodule Api.Mixfile do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :api,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Api.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:confex_config_provider, "~> 0.1.0"},
      {:rules, in_umbrella: true},
      {:eview, "~> 0.15"},
      {:jvalid, "~> 0.7.0"},
      {:phoenix, "~> 1.4"},
      {:jason, "~> 1.1"},
      {:cowboy, "~> 2.5"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
