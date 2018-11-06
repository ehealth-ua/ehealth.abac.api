defmodule Rules.Grpc.WorkerBehaviour do
  @moduledoc false

  @callback call(atom(), atom(), any()) :: {:ok, any()} | :error
end
