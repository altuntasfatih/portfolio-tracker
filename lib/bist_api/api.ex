defmodule PortfolioTracker.BistApi do
  alias PortfolioTracker.BistApi.Models.StockInfo

  @callback get_live_prices() :: {:ok, [StockInfo.t()]} | any
  @callback get_live_prices(list()) :: {:ok, [StockInfo.t()]} | any
end
