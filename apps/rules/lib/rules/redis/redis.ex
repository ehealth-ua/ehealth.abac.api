defmodule Rules.Redis do
  @moduledoc false

  use Confex, otp_app: :rules

  def get(key) when is_binary(key) do
    with {:ok, encoded_value} <- command(["GET", key]) do
      case encoded_value do
        nil -> {:error, :not_found}
        _ -> {:ok, decode(encoded_value)}
      end
    end
  end

  defp command(command) do
    Redix.command(:"redix_#{random_index()}", command)
  end

  defp encode(value), do: :erlang.term_to_binary(value)

  defp decode(value), do: :erlang.binary_to_term(value)

  defp random_index do
    rem(System.unique_integer([:positive]), config()[:pool_size])
  end
end
