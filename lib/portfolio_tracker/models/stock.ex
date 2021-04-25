defmodule Stock do
  import Util

  defstruct id: "",
            name: "",
            count: 0,
            purchase_price: 0.0,
            total_cost: 0.0,
            current_price: 0.0,
            current_worth: 0,
            rate: 0.0,
            alert: []

  def new(id, name, stock_count, purchase_price) do
    %Stock{
      id: id,
      name: name,
      count: stock_count,
      purchase_price: purchase_price,
      total_cost: (purchase_price * stock_count) |> round_ceil
    }
    |> calculate(purchase_price)
  end

  def calculate(%Stock{} = stock, purchase_price) do
    current_worth = (stock.count * purchase_price) |> round_ceil

    %Stock{
      stock
      | current_price: purchase_price,
        current_worth: current_worth,
        rate: ((current_worth - stock.total_cost) / stock.total_cost * 100) |> round_ceil
    }
  end

  def add_alert(%Stock{alert: current_alerts} = stock, %Alert{} = alert) do
    %Stock{
      stock
      | alert: [alert | current_alerts] |> Enum.reverse()
    }
  end

  def to_string(%Stock{} = stock) do
    "Name: #{stock.id} \nWorth: #{stock.current_worth} \nRate: #{rate(stock.rate)}"
  end

  def detailed_to_string(%Stock{} = stock) do
    "Name: #{stock.id} \nCount: #{stock.count} \nPurchase price: #{stock.purchase_price} \nCost: #{
      stock.total_cost
    } \nCurrent price: #{stock.current_price} \nWorth: #{stock.current_worth} \nRate: #{
      rate(stock.rate)
    }"
  end
end
