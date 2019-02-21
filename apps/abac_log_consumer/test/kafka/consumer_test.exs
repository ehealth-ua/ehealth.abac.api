defmodule AbacLogConsumer.Kafka.ConsumerTest do
  @moduledoc false

  use ExUnit.Case, async: true
  alias AbacLogConsumer.Kafka.Consumer
  alias Core.AuditLogs.Log
  alias Core.Mongo
  import Mox

  describe "consume/1" do
    test "success consume log" do
      expect(RpcWorkerMock, :run, fn _, _, :client_by_id, _ ->
        {:ok, %{name: "client name"}}
      end)

      id = Mongo.generate_id()

      log = %Log{
        consumer: %{"client_id" => UUID.uuid4(), "mis_client_id" => UUID.uuid4(), "user_id" => UUID.uuid4()},
        contexts: [%{"id" => UUID.uuid4(), "type" => "patient"}],
        resource: %{"action" => "read", "id" => UUID.uuid4(), "type" => "episode"},
        _id: id,
        inserted_at: NaiveDateTime.utc_now(),
        rule: %{
          name: "Doctor with active approval can read all the data of specified in approval patient",
          tag: :rule_2
        },
        result: true
      }

      assert :ok == Consumer.consume(log)
      assert %{"_id" => ^id} = Mongo.find_one(Log.collection(), %{_id: id})
    end
  end
end
