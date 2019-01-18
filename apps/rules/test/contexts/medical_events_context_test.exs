defmodule Rules.Features.MedicalEventsTest do
  @moduledoc false

  use ExUnit.Case, async: true
  alias Gherkin.Parser
  alias Rules.Parser
  alias WhiteBread.Runners.ScenarioRunner
  alias WhiteBread.Runners.Setup
  alias WhiteBread.Tags.FeatureFilterer
  import Mox

  @context Rules.Contexts.MedicalEventsContext

  setup :verify_on_exit!

  setup do
    features =
      Application.app_dir(:rules, "priv/features")
      |> Parser.parse_features()
      |> FeatureFilterer.get_for_tags([:medical_events])

    [feature: hd(features)]
  end

  test "test all scenarios", %{feature: feature} do
    patient_id = UUID.uuid4()
    client_id = UUID.uuid4()

    setup = %Setup{
      starting_state: %{
        validations: [],
        patient_id: patient_id,
        user_id: UUID.uuid4(),
        client_id: client_id,
        resource_id: UUID.uuid4()
      }
    }

    employee_ids = [UUID.uuid4()]
    declarations = [%{legal_entity_id: client_id}]

    stub(RpcWorkerMock, :run, fn
      "casher", _, :get_person_data, _ ->
        {:ok, %{person_ids: [patient_id]}}

      "ehealth", _, :employees_by_user_id_client_id, _ ->
        {:ok, employee_ids}

      "ops", _, :declarations_by_employees, _ ->
        {:ok, declarations}

      "medical_events_api", _, :episode_by_id, _ ->
        {:ok, %{care_manager: %{identifier: %{value: client_id}}}}
    end)

    Enum.all?(feature.scenarios, fn scenario ->
      result = ScenarioRunner.run(scenario, @context, setup)

      if scenario.name =~ "can't" or scenario.name =~ "approval" do
        assert {:failed, :error} = result
      else
        assert {:ok, _} = result
      end
    end)
  end
end
