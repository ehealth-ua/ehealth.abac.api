defmodule Rules.Context do
  @moduledoc false

  def add_validation(state, fun, args) do
    %{state | validations: state.validations ++ [{fun, args}]}
  end
end
