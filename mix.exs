defmodule Abac.MixProject do
  use Mix.Project

  @version "0.2.1"

  def project do
    [
      version: @version,
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:distillery, "~> 2.0"},
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:git_ops, "~> 0.6.0", only: [:dev]}
    ]
  end
end
