defmodule Rules.Validations.ReferralValidator do
  @moduledoc false

  @doc """
  Not implemented
  """
  def referral_msp_from_request(_patient_id, _user_id, _client_id) do
    :ok
  end

  @doc """
  For now should always return :error
  """
  def referral_msp_not_from_request(_patient_id, _user_id, _client_id) do
    :error
  end
end
