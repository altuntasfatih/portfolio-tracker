defmodule Stock do
  defstruct name: "",
            total: 0.0,
            cost_price: 0.0,
            cost: 0.0,
            price: 0.0,
            value: 0.0,
            rate: 0.0

  @type t :: %Stock{
          name: String.t(),
          total: float(),
          cost_price: float(),
          cost: float(),
          price: float(),
          value: float(),
          rate: float()
        }

  @spec new(String.t(), number(), float()) :: Stock.t()
  def new(name, total, price) do
    value = (total * price) |> Util.round_ceil()

    %Stock{
      name: name,
      total: total,
      cost_price: price,
      cost: value,
      price: price,
      value: value,
      rate: 0.0
    }
  end

  @spec update(Stock.t(), float()) :: Stock.t()
  def update(%Stock{} = stock, new_price) do
    value = (stock.total * new_price) |> Util.round_ceil()

    %Stock{
      stock
      | price: new_price,
        value: value,
        rate: ((value - stock.cost) / stock.cost * 100) |> Util.round_ceil()
    }
  end
end
