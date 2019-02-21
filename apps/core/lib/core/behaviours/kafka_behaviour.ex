defmodule Core.Behaviours.KafkaProducerBehaviour do
  @moduledoc false

  alias Core.AuditLogs.Log

  @callback publish_log(request :: any) ::
              :ok
              | {:ok, integer}
              | {:error, :closed}
              | {:error, :inet.posix()}
              | {:error, any}
              | iodata
              | :leader_not_available
end
