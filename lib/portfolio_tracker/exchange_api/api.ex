defmodule PortfolioTracker.ExchangeApi do
  alias PortfolioTracker.ExchangeApi.Models.StockInfo

  @callback get_live_prices() :: {:ok, [StockInfo.t()]} | any
  @callback get_live_prices(list()) :: {:ok, [StockInfo.t()]} | any
end
