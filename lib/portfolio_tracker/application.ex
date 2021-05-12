defmodule PortfolioTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application

  @env Mix.env()

  @impl true
  def start(_type, _args) do
    opts = [
      strategy: :one_for_one,
      max_restarts: 10,
      max_seconds: 20,
      name: PortfolioTracker.Supervisor
    ]

    Supervisor.start_link(children_by_env(@env), opts)
  end

  defp children_by_env(:test) do
    [{PortfolioTracker.ServerSupervisor, :ok}]
  end

  defp children_by_env(_) do
    [
      {PortfolioTracker.ServerSupervisor, :ok},
      # -1 is offset get last message
      {Bot.Manager, -1}
    ]
  end
end
