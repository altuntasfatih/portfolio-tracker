defmodule Asset do
  defstruct name: "",
            total: 0.0,
            cost_price: 0.0,
            cost: 0.0,
            price: 0.0,
            value: 0.0,
            rate: 0.0

  @type t :: %Asset{
          name: String.t(),
          total: float(),
          cost_price: float(),
          cost: float(),
          price: float(),
          value: float(),
          rate: float()
        }

  @spec new(String.t(), number(), float()) :: Asset.t()
  def new(name, total, price) do
    value = (total * price) |> Util.round_ceil()

    %Asset{
      name: name,
      total: total,
      cost_price: price,
      cost: value,
      price: price,
      value: value,
      rate: 0.0
    }
  end

  @spec update(Asset.t(), float()) :: Asset.t()
  def update(%Asset{} = a, new_price) do
    value = (a.total * new_price) |> Util.round_ceil()

    %Asset{
      a
      | price: new_price,
        value: value,
        rate: ((value - a.cost) / a.cost * 100) |> Util.round_ceil()
    }
  end
end
