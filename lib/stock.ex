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

  def new(id, name, stock_count, cost_per_stock) do
    %Stock{
      id: id,
      name: name,
      count: stock_count,
      total_cost: (cost_per_stock * stock_count) |> round_ceil
    }
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
end
