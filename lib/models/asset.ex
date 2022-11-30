defmodule Asset do
  defstruct id: "",
            name: "",
            total: 0.0,
            type: :crypto,
            cost_price: 0.0,
            cost: 0.0,
            price: 0.0,
            value: 0.0,
            rate: 0.0

  @type type :: :crypto | atom()
  @type t :: %Asset{
          id: String.t(),
          name: String.t(),
          type: type(),
          total: float(),
          cost_price: float(),
          cost: float(),
          price: float(),
          value: float(),
          rate: float()
        }

  @spec new(
          asset_id :: String.t(),
          asset_name :: String.t(),
          asset_count :: float(),
          asset_price :: float()
        ) :: Asset.t()
  def new(id, name, total, price) do
    value = (total * price) |> Util.round_ceil()

    %Asset{
      id: id,
      name: name,
      total: total,
      type: :crypto,
      cost_price: price,
      cost: value,
      price: price,
      value: value,
      rate: 0.0
    }
  end

  def new(name, total, price) do
    new(name, name, total, price)
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
