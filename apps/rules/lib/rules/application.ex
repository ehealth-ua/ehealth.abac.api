defmodule Rules.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Rules.Redis

  def start(_type, _args) do
    redix_config = Redis.config()

    redix_workers =
      for i <- 0..(redix_config[:pool_size] - 1) do
        %{
          id: {Redix, i},
          start:
            {Redix, :start_link,
             [
               [
                 host: redix_config[:host],
                 port: redix_config[:port],
                 password: redix_config[:password],
                 database: redix_config[:database],
                 name: :"redix_#{i}"
               ]
             ]}
        }
      end

    grpc_workers =
      if Confex.fetch_env!(:rules, :env) == "prod" do
        [
          {Rules.Grpc.Channels, []},
          {Rules.Grpc.Watcher, []}
        ]
      else
        []
      end

    children =
      redix_workers ++
        grpc_workers ++
        [
          {Rules.Grpc.Worker, []},
          {Rules.Parser, [Application.app_dir(:rules, "priv/features")]}
        ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rules.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
