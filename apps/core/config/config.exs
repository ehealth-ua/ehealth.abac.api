use Mix.Config

config :logger_json, :backend,
  formatter: EhealthLogger.Formatter,
  metadata: :all

config :logger,
  backends: [LoggerJSON],
  level: :debug

config :core, Core.Redis,
  host: {:system, "REDIS_HOST", "0.0.0.0"},
  port: {:system, :integer, "REDIS_PORT", 6379},
  password: {:system, "REDIS_PASSWORD", nil},
  database: {:system, "REDIS_DATABASE", nil},
  pool_size: {:system, :integer, "REDIS_POOL_SIZE", 5}

import_config "#{Mix.env()}.exs"
