use Mix.Config

config :kaffe,
  producer: [
    endpoints: {:system, :string, "KAFKA_BROKERS"},
    topics: ["abac_logs"]
  ]
