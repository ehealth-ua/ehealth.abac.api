defmodule AbacLogConsumer.Kafka.Consumer do
  @moduledoc false

  require Logger

  alias Core.AuditLogs.Log
  alias Core.Mongo

  @rpc_worker Application.get_env(:abac_log_consumer, :rpc_worker)

  def handle_message(%{offset: offset, value: value}) do
    value = :erlang.binary_to_term(value)
    Logger.debug(fn -> "message: " <> inspect(value) end)
    Logger.info(fn -> "offset: #{offset}" end)
    consume(value)
  end

  def consume(%Log{} = log) do
    with {:ok, client} <- @rpc_worker.run("mithril_api", Core.Rpc, :client_by_id, [log.consumer["client_id"]]) do
      log =
        %{log | consumer: Map.put(log.consumer, "client_name", client.name)}
        |> Mongo.convert_to_uuid(:consumer, ~w(client_id))
        |> Mongo.convert_to_uuid(:consumer, ~w(mis_client_id))
        |> Mongo.convert_to_uuid(:consumer, ~w(user_id))
        |> Mongo.convert_to_uuid(:contexts, ~w(id))
        |> Mongo.convert_to_uuid(:resource, ~w(id))

      case Mongo.update_one(
             Log.collection(),
             %{"_id" => log._id},
             %{"$set" => log |> Mongo.prepare_doc() |> Map.delete(:_id)},
             upsert: true
           ) do
        {:ok, _} ->
          :ok

        error ->
          Logger.error("Failed to insert log #{inspect(error)}")
          :error
      end
    end
  end

  def consume(event) do
    Logger.warn("Unknown event #{inspect(event)}")
  end
end
