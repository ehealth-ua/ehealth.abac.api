defmodule Rules.Contexts.PatientSummaryContext do
  @moduledoc false

  use WhiteBread.Context

  # scenario_finalize(fn {:ok, scenario}, state ->
  #   DecisionManager.decide(state)
  # end)

  @doc "Request access to resource by action name"
  when_(~r/^I require (?<action_name>(create|read|update|action)) access$/, fn
    state, %{action_name: _action_name} ->
      {:ok, state}
  end)

  @doc "Verify access to resource by action name"
  then_(~r/^I (?<has_access>(can|can't)) (?<action_name>(create|read|update|do action))$/, fn
    state, %{action_name: action_name, has_access: "can"} ->
      {:ok, Map.merge(state, %{"action_name" => action_name, "has_access" => true})}

    state, %{action_name: action_name, has_access: "can't"} ->
      {:ok, Map.merge(state, %{"action_name" => action_name, "has_access" => false})}
  end)
end
