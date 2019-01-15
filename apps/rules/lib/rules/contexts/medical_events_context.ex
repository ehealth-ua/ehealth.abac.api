defmodule Rules.Contexts.MedicalEventsContext do
  @moduledoc false

  use WhiteBread.Context
  alias Rules.DecisionManager
  alias Rules.Validations.DeclarationValidator
  alias Rules.Validations.MedicalEventsResourceValidator
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

  given_("declaration from the same MSP", fn state ->
    {:ok,
     add_validation(state, &DeclarationValidator.same_msp_declaration?/2, [
       state.client_id,
       state.user_id
     ])}
  end)

  given_("Active approval on patient", fn state ->
    {:ok, state}
  end)

  given_("Active approval on episode", fn state ->
    {:ok, state}
  end)

  given_(~r/^(?<resource>(\w+)) has been created on my MSP$/u, fn
    state, %{resource: resource_type} ->
      {:ok,
       add_validation(state, &MedicalEventsResourceValidator.same_msp_resource?/4, [
         state.client_id,
         String.downcase(resource_type),
         state.resource_id,
         state.patient_id
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
