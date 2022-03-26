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

    @env
    |> children()
    |> Supervisor.start_link(opts)
  end
  defp children(:test) do
    [{PortfolioTracker.Supervisor, :ok}]
  end

  defp children(_) do
    [
      {PortfolioTracker.Supervisor, :ok},
      {PortfolioTracker.Crypto.CoinGeckoCache, :ok},
      # -1 is offset get last message
      {PortfolioTracker.Bot.Server, -1}
    ]
  end
end
