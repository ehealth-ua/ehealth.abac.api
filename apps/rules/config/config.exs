use Mix.Config

config :kazan, :server, :in_cluster

config :rules,
  connections: [
    %{namespace: "il", endpoint_name: "api-grpc", stub: EHealthGrpc.Stub, timeout: 10_000},
    %{namespace: "il", endpoint_name: "casher-grpc", stub: CasherGrpc.Stub, timeout: 10_000}
  ],
  worker: Rules.Grpc.Worker

config :rules, Rules.Redis,
  host: {:system, "REDIS_HOST", "0.0.0.0"},
  port: {:system, :integer, "REDIS_PORT", 6379},
  password: {:system, "REDIS_PASSWORD", nil},
  database: {:system, "REDIS_DATABASE", nil},
  pool_size: {:system, :integer, "REDIS_POOL_SIZE", 5}

import_config "#{Mix.env()}.exs"
