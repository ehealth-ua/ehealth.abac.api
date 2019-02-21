use Mix.Config

config :abac_log_consumer, :mongo, url: {:system, :string, "DB_URL"}

config :abac_log_consumer,
  kaffe_consumer: [
    endpoints: {:system, :string, "KAFKA_BROKERS"},
    topics: ["abac_logs"],
    consumer_group: "abac_logs_group",
    message_handler: AbacLogConsumer.Kafka.Consumer
  ]
