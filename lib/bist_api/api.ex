defmodule PortfolioTracker.Bist.Api do
  alias PortfolioTracker.Bist.Api.Models.StockInfo

  @callback get_price(list()) ::
              {:error, any()} | {:ok, %{String.t() => StockInfo.t()}} | any
end
