defmodule StockPortfolio do
  import Util
  defstruct id: "", stocks: %{}, total_cost: 0.0, total_worth: 0.0, rate: 0.0, update_time: nil

  def new(id) do
    %StockPortfolio{id: id}
  end

  def get_stocks(%StockPortfolio{stocks: stocks}) do
    Map.values(stocks)
    |> Enum.sort(&(&1.rate >= &2.rate))
  end

  def add_stock(%StockPortfolio{} = portfolio, %Stock{} = new_stock) do
    Map.put(portfolio, :stocks, Map.put(portfolio.stocks, new_stock.id, new_stock))
    |> calculate()
  end

  def delete_stock(%StockPortfolio{} = portfolio, stock_id) do
    Map.put(portfolio, :stocks, Map.delete(portfolio.stocks, stock_id))
    |> calculate()
  end

  def update_stocks(%StockPortfolio{} = portfolio, new_stocks) do
    Map.put(portfolio, :stocks, new_stocks)
    |> calculate()
    |> Map.put(:update_time, NaiveDateTime.utc_now())
  end

  defp calculate(%StockPortfolio{stocks: stocks, id: id, update_time: time}) do
    Map.values(stocks)
    |> Enum.reduce(new(id), fn s, acc ->
      cost = (acc.total_cost + s.total_cost) |> round_()
      worth = (acc.total_worth + s.current_worth) |> round_()

      %StockPortfolio{
        acc
        | total_cost: cost,
          total_worth: worth,
          rate: ((worth - cost) / cost * 100) |> round_ceil
      }
    end)
    |> Map.put(:stocks, stocks)
    |> Map.put(:update_time, time)
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
      stocks =
        Enum.join(
          StockPortfolio.get_stocks(portfolio),
          " \n------------------------------------- \n"
        )

      "Portfolio Identity : #{portfolio.id} \nTotal Cost : #{portfolio.total_cost} \nTotal Worth : #{
        portfolio.total_worth
      } \nUpdate Time : #{portfolio.update_time} \nRate : #{rate(portfolio.rate)} \n------------------------------------- \n#{
        stocks
      } "
    end

    def rate(r) when r < 0, do: "#{r} 🔴 "
    def rate(r) when r >= 0, do: "#{r} 🟢 "
  end
end
