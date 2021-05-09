defmodule PortfolioTracker.ExchangeApi do
  @callback get_live_prices() :: {:ok, list} | any
  @callback get_live_prices(list()) :: {:ok, map()} | any

  def get_live_prices() do
    Application.get_env(:portfolio_tracker, :exchange_api).get_live_prices()
  end

  def get_live_prices(name_list) when is_list(name_list) do
    Application.get_env(:portfolio_tracker, :exchange_api).get_live_prices(name_list)
  end
end
