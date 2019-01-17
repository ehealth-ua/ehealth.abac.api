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

config :rules, Rules.Redis,
  host: {:system, "REDIS_HOST", "0.0.0.0"},
  port: {:system, :integer, "REDIS_PORT", 6379},
  password: {:system, "REDIS_PASSWORD", nil},
  database: {:system, "REDIS_DATABASE", nil},
  pool_size: {:system, :integer, "REDIS_POOL_SIZE", 5}

import_config "#{Mix.env()}.exs"
