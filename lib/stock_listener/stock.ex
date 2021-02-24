defmodule Stock do
  import Util

  defstruct id: "",
            name: "",
            count: 0,
            current_price: 0.0,
            total_cost: 0.0,
            current_worth: 0,
            rate: 0.0,
            target_price: 0

  def new(id, name, stock_count, current_price, target_price) do
    %Stock{
      id: id,
      name: name,
      count: stock_count,
      current_price: current_price,
      target_price: target_price,
      total_cost: (current_price * stock_count) |> round_ceil
    }
    |> calculate(current_price)
  end

  def calculate(%Stock{} = stock, current_price) do
    current_worth = (stock.count * current_price) |> round_ceil

    %Stock{
      stock
      | current_price: current_price,
        current_worth: current_worth,
        rate: ((current_worth - stock.total_cost) / stock.total_cost * 100) |> round_ceil
    }
  end

  defimpl String.Chars, for: Stock do
    def to_string(stock) do
      "stock_name -> #{stock.name}
       count: #{stock.count}
       total_cost: #{stock.total_cost}
       current_price: #{stock.current_price}
       current_worth: #{stock.current_worth}
       rate: #{stock.rate}"
    end
  end
end
