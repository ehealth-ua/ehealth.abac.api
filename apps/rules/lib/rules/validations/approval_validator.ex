defmodule Rules.Validations.ApprovalValidator do
  @moduledoc false

  def active_approval?(_), do: false
  def active_approval?(_, _), do: false
end
