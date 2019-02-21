defmodule Core.Application do
  @moduledoc false

  use Application
  alias Core.Redis

  def start(_type, _args) do
    redix_config = Redis.config()

    children =
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

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Core.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
