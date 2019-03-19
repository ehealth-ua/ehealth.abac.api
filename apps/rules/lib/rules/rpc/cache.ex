defmodule Rules.Rpc.Cache do
  @moduledoc """
  Cache for RPC requests
  """

  @rpc_worker Application.get_env(:rules, :rpc_worker)

  def run(basename, module, function, args) do
    case :ets.lookup(:cache, {basename, module, function, args}) do
      [] ->
        result = @rpc_worker.run(basename, module, function, args)
        :ets.insert(:cache, {{basename, module, function, args}, result})
        result

      [{_, value}] ->
        value
    end
  end
end
