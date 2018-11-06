defmodule ApiWeb.IndexController do
  @moduledoc false

  use ApiWeb, :controller

  alias Api.JsonSchema
  alias Rules.DecisionManager

  action_fallback(ApiWeb.FallbackController)

  def check(conn, params) do
    with :ok <- JsonSchema.validate(:check_request, params),
         result <- DecisionManager.check_access(params) do
      render(conn, "index.json", result: result)
    end
  end
end
