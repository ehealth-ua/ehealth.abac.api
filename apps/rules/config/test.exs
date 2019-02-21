use Mix.Config

config :rules,
  env: "test",
  rpc_worker: RpcWorkerMock,
  kafka: [producer: KafkaMock]
