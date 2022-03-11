defmodule PortfolioTracker.Bist.Api do
  alias PortfolioTracker.Bist.Api.Models.StockInfo

  @callback get_price(list()) ::
              {:error, any()} | {:ok, %{String.t() => StockInfo.t()}} | any()

  def get_price(list), do: impl().get_price(list)
  defp impl, do: Application.get_env(:portfolio_tracker, :bist)[:api]
end
