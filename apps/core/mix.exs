defmodule Core.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :core,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Core.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mongodb, "~> 0.4.7"},
      {:poolboy, "~> 1.5"},
      {:redix, "~> 0.8.2"},
      {:ehealth_logger, git: "https://github.com/edenlabllc/ehealth_logger.git"},
      {:uuid, "~> 1.1"}
    ]
  end
end
