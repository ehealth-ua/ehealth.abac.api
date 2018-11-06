defmodule ApiWeb.FallbackController do
  @moduledoc false

  use ApiWeb, :controller

  alias EView.Views.ValidationError

  require Logger

  def call(conn, {:error, json_schema_errors}) when is_list(json_schema_errors) do
    conn
    |> put_status(422)
    |> put_view(ValidationError)
    |> render("422.json", %{schema: json_schema_errors})
  end

  def call(conn, params) do
    Logger.error(fn ->
      Jason.encode!(%{
        "log_type" => "error",
        "message" => "No function clause matching in ApiWeb.FallbackController.call/2: #{inspect(params)}",
        "request_id" => Logger.metadata()[:request_id]
      })
    end)

    conn
    |> put_status(:not_implemented)
    |> render(Error, :"501")
  end
end
