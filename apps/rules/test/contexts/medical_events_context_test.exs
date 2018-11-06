defmodule Rules.Features.MedicalEventsTest do
  @moduledoc false

  use ExUnit.Case, async: true
  alias CasherProto.PersonDataResponse
  alias Gherkin.Parser
  alias Rules.Parser
  alias WhiteBread.Runners.ScenarioRunner
  alias WhiteBread.Runners.Setup
  alias WhiteBread.Tags.FeatureFilterer
  import Mox

  @context Rules.Contexts.MedicalEventsContext

  setup do
    features =
      Application.app_dir(:rules, "priv/features")
      |> Parser.parse_features()
      |> FeatureFilterer.get_for_tags([:medical_events])

    [feature: hd(features)]
  end

  test "test all scenarios", %{feature: feature} do
    patient_id = UUID.uuid4()

    setup = %Setup{
      starting_state: %{
        validations: [],
        patient_id: patient_id,
        user_id: UUID.uuid4(),
        client_id: UUID.uuid4()
      }
    }

    stub(WorkerMock, :call, fn CasherGrpc.Stub, :person_data, _ ->
      {:ok, %PersonDataResponse{person_ids: [patient_id]}}
    end)

    Enum.all?(feature.scenarios, fn scenario ->
      result = ScenarioRunner.run(scenario, @context, setup)

      if scenario.name =~ "can't" do
        assert {:failed, :error} = result
      else
        assert {:ok, _} = result
      end
    end)
  end
end
