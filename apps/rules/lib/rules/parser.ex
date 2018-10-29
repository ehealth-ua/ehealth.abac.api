defmodule Rules.Parser do
  @moduledoc """
  Load and parse rules definitions
  """

  use GenServer
  import WhiteBread.Feature.Finder, only: [find_in_path: 1]
  import Gherkin.Parser, only: [parse_feature: 2]

  def start_link(path) do
    GenServer.start_link(__MODULE__, path)
  end

  @impl true
  def init(path) do
    {:ok, %{features: parse_features(path)}}
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
end
