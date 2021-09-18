defmodule PortfolioTracker.CryptoApi do

  @callback get_live_prices(list()) :: {:ok, any()} | any
end
