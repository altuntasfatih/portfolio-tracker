defmodule PortfolioTracker.ExchangeApi do
  @callback get_live_prices() :: {:ok, list} | any

  def get_live_prices() do
    Application.get_env(:portfolio_tracker, :exchange_api).get_live_prices()
  end
end
