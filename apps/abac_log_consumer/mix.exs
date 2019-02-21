defmodule AbacLogConsumer.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :abac_log_consumer,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AbacLogConsumer.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  defp deps do
    [
      {:confex_config_provider, "~> 0.1.0"},
      {:kaffe, git: "https://github.com/AlexKovalevych/kaffe.git", branch: "string_endpoints"},
      {:kube_rpc, git: "https://github.com/edenlabllc/kube_rpc.git"},
      {:libcluster, "~> 3.0", git: "https://github.com/AlexKovalevych/libcluster.git", branch: "kube_namespaces"},
      {:mox, "~> 0.4.0", only: :test},
      {:core, in_umbrella: true}
    ]
  end

  defp aliases do
    [
      reset: ["drop"],
      test: ["reset", "test"]
    ]
  end
end
