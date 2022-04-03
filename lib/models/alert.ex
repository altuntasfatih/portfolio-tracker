defmodule Alert do
  defstruct type: nil,
            asset_id: "",
            asset_type: nil,
            target: 0.0,
            condition: nil

  @type t :: %Alert{
          type: atom(),
          asset_id: String.t(),
          asset_type: Asset.type(),
          target: float(),
          condition: function()
        }

  @spec new(:lower_limit | :upper_limit, String.t(), Asset.type(), float()) :: Alert.t()
  def new(:lower_limit, asset_id, asset_type, price) when is_atom(asset_type) do
    %Alert{
      type: :lower_limit,
      asset_id: asset_id,
      asset_type: asset_type,
      target: price,
      condition: fn current_price ->
        current_price <= price
      end
    }
  end

  def new(:upper_limit, asset_id, asset_type, price) when is_atom(asset_type) do
    %Alert{
      type: :upper_limit,
      asset_id: asset_id,
      asset_type: asset_type,
      target: price,
      condition: fn current_price ->
        current_price >= price
      end
    }
  end

  @spec is_hit(Alert.t(), float()) :: boolean()
  def is_hit(%Alert{} = alert, current_price) when is_number(current_price),
    do: alert.condition.(current_price)

  def is_hit(%Alert{} = _, _), do: false
end
