use Mix.Config

config :rules,
  env: Mix.env(),
  rpc_worker: Rules.Rpc.Worker

config :rules,
  topologies: [
    k8s_casher: [
      strategy: Elixir.Cluster.Strategy.Kubernetes,
      config: [
        mode: :dns,
        kubernetes_node_basename: "casher",
        kubernetes_selector: "app=casher",
        kubernetes_namespace: "il",
        polling_interval: 10_000
      ]
    ],
    k8s_ehealth: [
      strategy: Elixir.Cluster.Strategy.Kubernetes,
      config: [
        mode: :dns,
        kubernetes_node_basename: "ehealth",
        kubernetes_selector: "app=ehealth",
        kubernetes_namespace: "il",
        polling_interval: 10_000
      ]
    ],
    k8s_ops: [
      strategy: Elixir.Cluster.Strategy.Kubernetes,
      config: [
        mode: :dns,
        kubernetes_node_basename: "ops",
        kubernetes_selector: "app=api",
        kubernetes_namespace: "ops",
        polling_interval: 10_000
      ]
    ],
    k8s_me: [
      strategy: Elixir.Cluster.Strategy.Kubernetes,
      config: [
        mode: :dns,
        kubernetes_node_basename: "medical_events_api",
        kubernetes_selector: "app=api-medical-events",
        kubernetes_namespace: "me",
        polling_interval: 10_000
      ]
    ]
  ]

config :kaffe,
  producer: [
    endpoints: [localhost: 9092],
    topics: ["abac_logs"]
  ]

config :rules, :kafka, producer: Rules.Kafka.Producer

config :rules, Rules.Rpc.Cache, cache_ttl: {:system, :integer, "RPC_CACHE_TTL", 60}

import_config "#{Mix.env()}.exs"
