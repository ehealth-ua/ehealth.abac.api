defmodule Rules.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Rules.Parser, [Application.app_dir(:rules, "priv/features")]}
    ]

    children =
      if Application.get_env(:rules, :env) == :prod do
        children ++
          [
            {Cluster.Supervisor, [Application.get_env(:rules, :topologies), [name: Rules.ClusterSupervisor]]}
          ]
      else
        children
      end

    opts = [strategy: :one_for_one, name: Rules.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
