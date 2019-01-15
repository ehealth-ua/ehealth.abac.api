defmodule ApiWeb.IndexController do
  @moduledoc false

  use ApiWeb, :controller

  alias Api.JsonSchema
  alias Rules.DecisionManager

  action_fallback(ApiWeb.FallbackController)

  def authorize(conn, params) do
    with :ok <- JsonSchema.validate(:authorize_request, params),
         result <- DecisionManager.check_access(params) do
      render(conn, "index.json", result: result)
    end
  end
end
