defmodule AbacLogConsumer.Rpc.Worker do
  @moduledoc false

  use KubeRPC.Client, :abac_log_consumer
end
