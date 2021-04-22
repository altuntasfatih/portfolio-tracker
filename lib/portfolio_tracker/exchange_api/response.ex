defmodule PortfolioTracker.ExchangeApi.StockPricesResponse do
  alias PortfolioTracker.ExchangeApi.StockPricesResponse
  defstruct success: false, result: []

  @spec parse(binary) :: list
  def parse(body) when is_binary(body) do
    struct(%StockPricesResponse{}, Jason.decode!(body, keys: :atoms))
    |> get_stocks()
  end

  defp get_stocks(%StockPricesResponse{success: true, result: prices}), do: prices
  defp get_stocks(%StockPricesResponse{success: false}), do: []
end
