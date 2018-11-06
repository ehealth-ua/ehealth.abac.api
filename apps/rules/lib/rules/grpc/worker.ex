defmodule Rules.Grpc.Worker do
  @moduledoc false

  use GenServer
  alias GRPC.Channel
  alias Rules.Grpc.Channels
  alias Rules.Grpc.WorkerBehaviour
  require Logger

  @behaviour WorkerBehaviour

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(arg) do
    {:ok, arg}
  end

  @impl true
  @doc "Currently implemented random strategy"
  def handle_call({:get_channel, namespace, endpoint}, _, state) do
    channels = Channels.get_channels(namespace, endpoint)

    channel =
      case channels do
        [] -> nil
        _ -> Enum.random(channels)
      end

    {:reply, channel, state}
  end

  @impl true
  def call(stub, function, request) do
    connection =
      Enum.reduce_while(get_connections(), :error, fn
        %{stub: connection_stub} = connection, acc ->
          if connection_stub == stub do
            {:halt, connection}
          else
            {:cont, acc}
          end
      end)

    with %{} <- connection,
         %Channel{} = channel <-
           GenServer.call(
             __MODULE__,
             {:get_channel, connection.namespace, connection.endpoint_name}
           ),
         {:ok, response} <- do_call(stub, function, [channel, request], 0) do
      {:ok, response}
    end
  end

  defp do_call(module, function, args, 3) do
    Logger.error("Failed to call rpc: #{module}.#{function} with args: #{inspect(args)}")
    :error
  end

  defp do_call(module, function, args, attempt) do
    case apply(module, function, args) do
      {:ok, response} -> {:ok, response}
      _ -> do_call(module, function, args, attempt + 1)
    end
  end

  defp get_connections do
    Application.get_env(:rules, :connections)
  end
end
