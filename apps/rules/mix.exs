defmodule Rules.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :rules,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
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
      {:kube_rpc, "~> 0.1.0"},
      {:kaffe, "~> 1.11"},
      {:libcluster, "~> 3.0", git: "https://github.com/AlexKovalevych/libcluster.git", branch: "kube_namespaces"},
      {:white_bread, "~> 4.5"},
      {:gherkin, "~> 1.6"},
      {:mox, "~> 0.4.0", only: :test},
      {:core, in_umbrella: true}
    ]
  end
end
