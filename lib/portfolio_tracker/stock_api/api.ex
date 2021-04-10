defmodule PortfolioTracker.StockApi do
  @callback get_live_prices() :: {:ok, list} | any

  def get_live_prices() do
    Application.get_env(:portfolio_tracker, :stock_api).get_live_prices()
  end
end
