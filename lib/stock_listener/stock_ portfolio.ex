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

  def delete_stock(%StockPortfolio{} = portfolio, stock_id) do
    Map.put(portfolio, :stocks, Enum.filter(portfolio.stocks, &(&1.id != stock_id)))
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
    @spec to_string(
            atom
            | %{
                :id => any,
                :rate => any,
                :stocks => any,
                :total_cost => any,
                :total_worth => any,
                optional(any) => any
              }
          ) :: <<_::64, _::_*8>>
    def to_string(portfolio) do
      stocks = Enum.join(portfolio.stocks, ",\n")
      "Portfolio -> #{portfolio.id}
       total_cost: #{portfolio.total_cost}
       total_worth: #{portfolio.total_worth}
       rate: #{portfolio.rate}
       stocks: \n #{stocks}"
    end
  end
end
