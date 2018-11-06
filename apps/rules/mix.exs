defmodule Rules.MixProject do
  use Mix.Project

  def project do
    [
      app: :rules,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Rules.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:redix, "~> 0.8.2"},
      {:confex, "~> 3.3"},
      {:mox, "~> 0.4.0"},
      {:grpc, "~> 0.3.0-alpha.2"},
      {:kazan, "~> 0.10.0"},
      {:white_bread, "~> 4.3"},
      {:uuid, "~> 1.1"}
    ]
  end
end
