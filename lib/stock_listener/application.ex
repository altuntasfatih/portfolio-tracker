defmodule StockListener.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {StockListener.MySupervisor, :ok},
      # -1 is offset get last message
      {Bot.Pooler, -1}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StockListener.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
