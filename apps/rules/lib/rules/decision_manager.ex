defmodule Rules.DecisionManager do
  @moduledoc false

  alias Core.AuditLogs.Log
  alias Gherkin.Elements.Feature
  alias Gherkin.Elements.Scenario
  alias Rules.Parser
  alias WhiteBread.Runners.ScenarioRunner
  alias WhiteBread.Runners.Setup
  require Logger

  @medical_events_resources ~w(
    encounter
    episode
    observation
    condition
    immunization
    allergy_intolerance
    risk_assessment
    device
    medication_statement
  )
  @medical_events_context Rules.Contexts.MedicalEventsContext

  @kafka_producer Application.get_env(:rules, :kafka)[:producer]

  def check_access(%{"resource" => %{"type" => type, "action" => action}} = params)
      when type in @medical_events_resources do
    [%Feature{scenarios: scenarios}] = Parser.get_scenarios(:medical_events, action, type)

    patient = Enum.find(params["contexts"] || [], &(Map.get(&1, "type") == "patient")) || %{}

    setup = %Setup{
      starting_state: %{
        validations: [],
        patient_id: patient["id"],
        resource_type: type,
        resource_id: params["resource"]["id"],
        user_id: params["consumer"]["user_id"],
        client_id: params["consumer"]["client_id"],
        client_type: params["consumer"]["client_type"],
        contexts: params["contexts"]
      }
    }

    {result, scenario} =
      Enum.reduce_while(scenarios, {false, nil}, fn scenario, acc ->
        case ScenarioRunner.run(scenario, @medical_events_context, setup) do
          {:ok, _} ->
            {:halt, {true, scenario}}

          _ ->
            {:cont, acc}
        end
      end)

    name = if scenario, do: scenario.name, else: nil
    tag = if result, do: scenario_tag(scenario), else: nil
    log = Log.create(params["consumer"], params["resource"], params["contexts"], result, name, tag)

    case @kafka_producer.publish_log(log) do
      :ok -> :ok
      error -> Logger.warn("Failed to publish log event. #{inspect(error)}")
    end

    result
  end

  def check_access(_) do
    false
  end

  def has_access?(%{validations: validations}) do
    Enum.all?(validations, fn {fun, args} ->
      apply(fun, args)
    end)
  end

  defp scenario_tag(%Scenario{tags: tags}) do
    Enum.find(tags, fn tag ->
      String.starts_with?(to_string(tag), "rule_")
    end)
  end
end
