defmodule ApiWeb.IndexView do
  @moduledoc false

  use ApiWeb, :view

  def render("index.json", %{result: result}) do
    %{result: result}
  end
end
