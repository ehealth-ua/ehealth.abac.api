defmodule Api.JsonSchema do
  @moduledoc false

  use JValid

  use_schema(:authorize_request, "json_schemas/authorize_request.json")

  def validate(schema, attrs) do
    @schemas
    |> Keyword.get(schema)
    |> validate_schema(attrs)
  end
end
