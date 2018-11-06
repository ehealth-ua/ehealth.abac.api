defmodule Api.JsonSchema do
  @moduledoc false

  use JValid

  use_schema(:check_request, "json_schemas/check_request.json")

  def validate(schema, attrs) do
    @schemas
    |> Keyword.get(schema)
    |> validate_schema(attrs)
  end
end
