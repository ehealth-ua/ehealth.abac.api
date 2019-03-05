use Mix.Config

config :abac_log_consumer,
  env: Mix.env(),
  rpc_worker: AbacLogConsumer.Rpc.Worker

config :abac_log_consumer,
  topologies: [
    k8s_mithril: [
      strategy: Elixir.Cluster.Strategy.Kubernetes,
      config: [
        mode: :dns,
        kubernetes_node_basename: "mithril_api",
        kubernetes_selector: "app=api",
        kubernetes_namespace: "mithril",
        polling_interval: 10_000
      ]
    ]
  ]

config :abac_log_consumer,
  kaffe_consumer: [
    endpoints: [localhost: 9092],
    topics: ["abac_logs"],
    consumer_group: "abac_logs_group",
    message_handler: AbacLogConsumer.Kafka.Consumer
  ]

import_config "#{Mix.env()}.exs"
