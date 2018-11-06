defmodule Rules.DecisionManager do
  @moduledoc false

  alias Gherkin.Elements.Feature
  alias Rules.Parser
  alias WhiteBread.Runners.ScenarioRunner
  alias WhiteBread.Runners.Setup

  @medical_events_resources ~w(encounter episode observation condition immunization allergy_intolerance)
  @medical_events_context Rules.Contexts.MedicalEventsContext

  def check_access(%{"resource" => %{"resource" => %{"type" => type}}} = params)
      when type in @medical_events_resources do
    [%Feature{scenarios: scenarios}] = Parser.get_scenarios(:medical_events, params["action"])

    patient =
      Enum.find(params["resource"]["context"] || [], &(Map.get(&1, "type") == "patient")) || %{}

    setup = %Setup{
      starting_state: %{
        validations: [],
        patient_id: patient["id"],
        resource_type: type,
        resource_id: params["resource"]["resource"]["id"],
        user_id: params["consumer"]["user_id"],
        client_id: params["consumer"]["client_id"],
        client_type: params["consumer"]["client_type"]
      }
    }

    Enum.reduce_while(scenarios, false, fn scenario, acc ->
      case ScenarioRunner.run(scenario, @medical_events_context, setup) do
        {:ok, _} -> {:halt, true}
        _ -> {:cont, acc}
      end
    end)
  end

  @doc """
  Not implemented
  """
  def check_access(%{"resource" => %{"resource" => %{"type" => "patient_summary"}}} = params) do
    true
  end

  @doc """
  Not implemented
  """
  def check_access(%{"resource" => %{"resource" => %{"type" => "referral"}}} = params) do
    true
  end

  def check_access(_) do
    false
  end

  def has_access?(%{validations: validations}) do
    Enum.all?(validations, fn {fun, args} ->
      apply(fun, args)
    end)
  end
end
