defmodule PortfolioTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {PortfolioTracker.CustomSupervisor, :ok},
      # -1 is offset get last message
      {Bot.Pooler, -1}
    ]

    opts = [strategy: :one_for_one, name: PortfolioTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
