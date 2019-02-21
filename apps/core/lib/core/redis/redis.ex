defmodule Core.Redis do
  @moduledoc false

  use Confex, otp_app: :core
  require Logger

  def get(key) when is_binary(key) do
    with {:ok, encoded_value} <- command(["GET", key]) do
      case encoded_value do
        nil -> {:error, :not_found}
        _ -> {:ok, decode(encoded_value)}
      end
    end
  end

  def setex(key, ttl_seconds, value) when is_binary(key) and is_integer(ttl_seconds) and value != nil do
    params = ["SETEX", key, ttl_seconds, encode(value)]

    case command(params) do
      {:ok, _} ->
        :ok

      {:error, reason} = err ->
        Logger.error("Fail to set redis key with params #{inspect(params)} with error #{inspect(reason)}")
        err
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
