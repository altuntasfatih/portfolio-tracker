defmodule PortfolioTracker.ExchangeApi do
  @callback get_live_prices() :: {:ok, list} | any
  @callback get_live_prices(list()) :: {:ok, list()} | any

  @spec get_live_prices :: {:ok, any()}
  def get_live_prices() do
    Application.get_env(:portfolio_tracker, :exchange_api).get_live_prices()
  end

  @spec get_live_prices(list()) :: {:ok, any()}
  def get_live_prices(name_list) when is_list(name_list) do
    Application.get_env(:portfolio_tracker, :exchange_api).get_live_prices(name_list)
  end
end
