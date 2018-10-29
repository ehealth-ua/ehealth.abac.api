defmodule Rules.Features.MedicalEventsTest do
  @moduledoc false

  use ExUnit.Case, async: true
  alias Gherkin.Parser
  alias Rules.Parser
  alias WhiteBread.Feature.Finder
  alias WhiteBread.Runners.ScenarioRunner
  alias WhiteBread.Runners.Setup
  alias WhiteBread.Tags.FeatureFilterer

  @context Rules.Contexts.MedicalEventsContext

  setup do
    features =
      Application.app_dir(:rules, "priv/features")
      |> Parse.parse_features()
      |> FeatureFilterer.get_for_tags([:medical_events])

    [feature: hd(features)]
  end

  test "test all contexts", %{feature: feature} do
    setup = %Setup{starting_state: %{}}

    Enum.all?(feature.scenarios, fn scenario ->
      assert {:ok, _} = ScenarioRunner.run(scenario, @context, setup)
    end)
  end
end
