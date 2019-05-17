defmodule Rules.Rpc.Cache do
  @moduledoc """
  Cache for RPC requests
  """

  alias Core.Redis
  use Confex, otp_app: :rules

  @rpc_worker Application.get_env(:rules, :rpc_worker)

  def run(basename, module, function, args) do
    hash =
      :md5
      |> :crypto.hash(inspect(args))
      |> Base.encode16()

    key = "rpc:#{basename}:#{module}.#{function}:#{hash}"

    case Redis.get(key) do
      {:ok, result} ->
        :erlang.binary_to_term(result)

      _ ->
        result = @rpc_worker.run(basename, module, function, args)
        Redis.setex(key, config()[:cache_ttl], :erlang.term_to_binary(result))
        result
    end
  end
end
