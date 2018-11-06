defmodule Rules.Contexts.MedicalEventsContext do
  @moduledoc false

  use WhiteBread.Context
  alias Rules.DecisionManager
  alias Rules.Validations.CareLevelValidator
  alias Rules.Validations.DeclarationValidator
  alias Rules.Validations.LegalEntityValidator
  alias Rules.Validations.ReferralValidator
  import Rules.Context

  @doc "Verify doctor has active declaration with patient"
  given_("Active declaration with patient", fn state ->
    {:ok,
     add_validation(state, &DeclarationValidator.has_active_declaration?/3, [
       state.patient_id,
       state.user_id,
       state.client_id
     ])}
  end)

  @doc "Verify MSP matches or differs from MSP from request"
  given_(~r/^MSP (?<is_equal>(=|!=)) MSP from request$/, fn
    # MSP should be equal to MSP from request
    state, %{is_equal: "="} ->
      {:ok,
       add_validation(state, &LegalEntityValidator.msp_from_request/3, [
         state.patient_id,
         state.user_id,
         state.client_id
       ])}

    # MSP should not be equal to MSP from request
    state, %{is_equal: "!="} ->
      {:ok,
       add_validation(state, &LegalEntityValidator.msp_not_from_request/3, [
         state.patient_id,
         state.user_id,
         state.client_id
       ])}
  end)

  @doc "Verify care level matches or differs from care level from request"
  given_(~r/^care level (?<is_equal>(=|!=)) care level from request$/, fn
    # care level should be equal to care level from request
    state, %{is_equal: "="} ->
      {:ok,
       add_validation(state, &CareLevelValidator.care_level_from_request/3, [
         state.patient_id,
         state.user_id,
         state.client_id
       ])}

    # care level should not be equal to care level from request
    state, %{is_equal: "!="} ->
      {:ok,
       add_validation(state, &CareLevelValidator.care_level_not_from_request/3, [
         state.patient_id,
         state.user_id,
         state.client_id
       ])}
  end)

  @doc "Verify referral MSP matches or differs MSP from request"
  given_(~r/^referral MSP (?<is_equal>(=|!=)) MSP from request$/, fn
    # referral MSP should be equal to MSP from request
    state, %{is_equal: "="} ->
      {:ok,
       add_validation(state, &ReferralValidator.referral_msp_from_request/3, [
         state.patient_id,
         state.user_id,
         state.client_id
       ])}

    # referral MSP should not be equal to MSP from request
    state, %{is_equal: "!="} ->
      {:ok,
       add_validation(state, &ReferralValidator.referral_msp_not_from_request/3, [
         state.patient_id,
         state.user_id,
         state.client_id
       ])}
  end)

  @doc "Request access to resource by action name"
  when_(~r/^I require (?<action_name>(create|read|update|action)) access$/, fn
    state, %{action_name: _action_name} ->
      {:ok, state}
  end)

  @doc "Verify access to resource by action name"
  then_(~r/^I (?<has_access>(can|can't)) (?<action_name>(create|read|update|do action))$/, fn
    state, %{has_access: "can"} ->
      if DecisionManager.has_access?(state), do: :ok, else: :error

    _, %{has_access: "can't"} ->
      :error
  end)
end
