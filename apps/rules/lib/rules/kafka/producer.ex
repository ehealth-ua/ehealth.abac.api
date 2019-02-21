defmodule Rules.Kafka.Producer do
  @moduledoc false

  alias Core.AuditLogs.Log
  require Logger

  @abac_logs_topic "abac_logs"

  @behaviour Core.Behaviours.KafkaProducerBehaviour

  def publish_log(%Log{} = log) do
    key = log.id
    Logger.info("Publishing kafka event to topic: #{@abac_logs_topic}, key: #{key}")
    Kaffe.Producer.produce_sync(@abac_logs_topic, 0, key, :erlang.term_to_binary(log))
  end
end
