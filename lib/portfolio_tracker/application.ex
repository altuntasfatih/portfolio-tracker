defmodule PortfolioTracker.Application do
  @moduledoc false
  use Application

  @env Mix.env()

  @impl true
  def start(_type, _args) do
    opts = [
      strategy: :one_for_one,
      max_restarts: 10,
      max_seconds: 20,
      name: PortfolioTracker.BaseSupervisor
    ]

    Supervisor.start_link(children_by_env(@env), opts)
  end

  defp children_by_env(:test) do
    [{PortfolioTracker.Supervisor, :ok}]
  end

  defp children_by_env(_) do
    [
      {PortfolioTracker.Supervisor, :ok},
      # -1 is offset get last message
      {PortfolioTracker.BotServer, -1}
    ]
  end
end
