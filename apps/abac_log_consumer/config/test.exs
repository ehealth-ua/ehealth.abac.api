use Mix.Config

config :abac_log_consumer,
  env: "test",
  rpc_worker: RpcWorkerMock

config :abac_log_consumer, :mongo, url: "mongodb://localhost:27017/abac_logs_test"
