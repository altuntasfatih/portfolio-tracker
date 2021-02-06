defmodule StockPortfolio do
  import Util
  defstruct id: "fatih", stocks: [], total_cost: 0.0, total_worth: 0.0, rate: 0.0

  def new(id) do
    %StockPortfolio{id: id}
  end

  def add_stock(%StockPortfolio{} = portfolio, %Stock{} = new_stock) do
    Map.put(portfolio, :stocks, [new_stock | portfolio.stocks])
    |> calculate()
  end

  def update_stocks(%StockPortfolio{} = portfolio, new_stocks) do
    Map.put(portfolio, :stocks, new_stocks)
    |> calculate()
  end

  defp calculate(%StockPortfolio{} = portfolio) do
    Enum.reduce(portfolio.stocks, %StockPortfolio{}, fn s, acc ->
      cost = (acc.total_cost + s.total_cost) |> round_ceil
      worth = (acc.total_worth + s.current_worth) |> round_ceil

      %StockPortfolio{
        acc
        | stocks: [s | acc.stocks],
          total_cost: cost,
          total_worth: worth,
          rate: ((worth - cost) / cost * 100) |> round_ceil
      }
    end)
  end
end
