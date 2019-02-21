defmodule AbacLogConsumer.Application do
  @moduledoc false

  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    children = [
      %{
        id: Kaffe.Consumer,
        start: {Kaffe.Consumer, :start_link, []}
      },
      worker(Mongo, [
        [name: :mongo, url: Application.get_env(:abac_log_consumer, :mongo)[:url], pool: DBConnection.Poolboy]
      ])
    ]

    Application.put_env(:kaffe, :consumer, Application.get_env(:abac_log_consumer, :kaffe_consumer))

    children =
      if Application.get_env(:abac_log_consumer, :env) == :prod do
        children ++
          [
            {Cluster.Supervisor,
             [Application.get_env(:abac_log_consumer, :topologies), [name: AbacLogConsumer.ClusterSupervisor]]}
          ]
      else
        children
      end

    opts = [strategy: :one_for_one, name: AbacLogConsumer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
