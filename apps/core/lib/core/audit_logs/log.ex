defmodule Core.AuditLogs.Log do
  @moduledoc false

  @collection "abac_logs"

  alias Core.Mongo

  def collection, do: @collection

  defstruct _id: nil,
            consumer: nil,
            resource: nil,
            contexts: [],
            rule: nil,
            result: nil,
            inserted_at: nil

  def create(consumer, resource, contexts, result, scenario_name, scenario_tag) do
    %__MODULE__{
      _id: Mongo.generate_id(),
      consumer: consumer,
      resource: resource,
      contexts: contexts,
      result: result,
      rule: %{
        name: scenario_name,
        tag: scenario_tag
      },
      inserted_at: DateTime.utc_now()
    }
  end
end
