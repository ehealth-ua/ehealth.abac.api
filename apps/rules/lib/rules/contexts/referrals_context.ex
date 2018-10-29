defmodule Rules.Contexts.ReferralsContext do
  @moduledoc false

  use WhiteBread.Context

  # scenario_finalize(fn {:ok, scenario}, state ->
  #   DecisionManager.decide(state)
  # end)

  @doc "Verify MSP matches or differs from MSP from request"
  given_(~r/^MSP (?<is_equal>(=|!=)) MSP from request$/, fn
    # MSP should be equal to MSP from request
    state, %{is_equal: "="} ->
      {:ok, state}

    # MSP should not be equal to MSP from request
    state, %{is_equal: "!="} ->
      {:ok, state}
  end)

  @doc "Verify care level matches or differs from care level from request"
  given_(~r/^care level (?<is_equal>(=|!=)) care level from request$/, fn
    # care level should be equal to care level from request
    state, %{is_equal: "="} ->
      {:ok, state}

    # care level should not be equal to care level from request
    state, %{is_equal: "!="} ->
      {:ok, state}
  end)

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
