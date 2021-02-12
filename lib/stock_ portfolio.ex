defmodule StockPortfolio do
  import Util
  defstruct id: "", stocks: [], total_cost: 0.0, total_worth: 0.0, rate: 0.0

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
    Enum.reduce(portfolio.stocks, %StockPortfolio{id: portfolio.id}, fn s, acc ->
      cost = (acc.total_cost + s.total_cost) |> round_()
      worth = (acc.total_worth + s.current_worth) |> round_()

      %StockPortfolio{
        acc
        | stocks: [s | acc.stocks],
          total_cost: cost,
          total_worth: worth,
          rate: ((worth - cost) / cost * 100) |> round_ceil
      }
    end)
  end

  defimpl String.Chars, for: StockPortfolio do
    def to_string(portfolio) do
      "%{id: #{portfolio.id}, total_cost: #{portfolio.total_cost}, total_worth: #{
        portfolio.total_worth
      }, rate: #{portfolio.rate} }"
    end
  end
end
