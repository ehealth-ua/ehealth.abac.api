defmodule Mix.Tasks.Drop do
  @moduledoc false

  use Mix.Task
  alias Core.Mongo
  require Logger

  def run(_) do
    {:ok, _} = Application.ensure_all_started(:mongodb)

    pid =
      case Mongo.start_link(
             name: :mongo,
             url: Application.get_env(:abac_log_consumer, :mongo)[:url],
             pool: DBConnection.Poolboy
           ) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
      end

    Mongo.command!(dropDatabase: 1)
    Logger.info(IO.ANSI.green() <> "Database dropped" <> IO.ANSI.default_color())

    GenServer.stop(pid)
  end
end
