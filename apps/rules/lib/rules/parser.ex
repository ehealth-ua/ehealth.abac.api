defmodule Rules.Parser do
  @moduledoc """
  Load and parse rules definitions
  """

  use GenServer
  alias WhiteBread.Tags.FeatureFilterer
  import WhiteBread.Feature.Finder, only: [find_in_path: 1]
  import Gherkin.Parser, only: [parse_feature: 2]

  @ets_pid :features

  def start_link(path) do
    GenServer.start_link(__MODULE__, path)
  end

  @impl true
  def init(path) do
    :ets.new(@ets_pid, [:set, :named_table])
    :ets.insert(@ets_pid, {:features, parse_features(path)})
    {:ok, %{path: path}}
  end

  def parse_features(path) do
    path
    |> Path.join("*")
    |> find_in_path()
    |> Stream.map(&{&1, File.read!(&1)})
    |> Enum.map(fn {file_name, feature_text} ->
      parse_feature(feature_text, file_name)
    end)
  end

  def get_scenarios(type, action, resource) when is_atom(type) do
    [features: features] = :ets.lookup(@ets_pid, :features)

    feature =
      features
      |> FeatureFilterer.get_for_tags([type])
      |> List.first() || %{}

    feature
    |> Map.get(:scenarios)
    |> Enum.filter(fn scenario ->
      String.to_atom(action) in scenario.tags and String.to_atom(resource) in scenario.tags
    end)
  end
end
