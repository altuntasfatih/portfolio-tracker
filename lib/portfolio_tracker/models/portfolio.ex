defmodule Portfolio do
  import Util

  defstruct id: "",
            assets: %{},
            cost: 0.0,
            value: 0.0,
            rate: 0.0,
            alerts: [],
            last_update_time: nil

  @type t :: %Portfolio{
          id: String.t(),
          assets: map(),
          cost: float(),
          value: float(),
          rate: float(),
          alerts: [Alert.t()],
          last_update_time: any()
        }

  def new(id), do: %Portfolio{id: id}

  def get_assets_by_order(%Portfolio{assets: assets}) do
    Map.values(assets)
    |> Enum.sort(&(&1.rate >= &2.rate))
  end

  @spec add_asset(Portfolio.t(), Asset.t()) :: Portfolio.t()
  def add_asset(%Portfolio{} = portfolio, %Asset{} = new_asset) do
    Map.put(portfolio, :assets, Map.put(portfolio.assets, new_asset.name, new_asset))
    |> calculate()
  end

  @spec remove_asset(Portfolio.t(), String.t()) :: Portfolio.t()
  def remove_asset(%Portfolio{} = portfolio, asset_name) do
    Map.put(portfolio, :assets, Map.delete(portfolio.assets, asset_name))
    |> calculate()
  end

  @spec add_alert(Portfolio.t(), Alert.t()) :: Portfolio.t()
  def add_alert(%Portfolio{alerts: current_alerts} = p, %Alert{} = alert) do
    %Portfolio{
      p
      | alerts: [alert | current_alerts] |> Enum.reverse()
    }
  end

  @spec remove_alert(Portfolio.t(), String.t()) :: Portfolio.t()
  def remove_alert(%Portfolio{alerts: current_alerts} = p, asset_name) do
    %Portfolio{
      p
      | alerts: current_alerts |> Enum.filter(&(&1.asset_name != asset_name))
    }
  end

  @spec update(Portfolio.t(), map()) :: Portfolio.t()
  def update(%Portfolio{} = portfolio, %{} = new_assets) do
    Map.put(portfolio, :assets, new_assets)
    |> calculate()
    |> Map.put(:update_time, current_time())
  end

  defp calculate(%Portfolio{assets: assets} = p) do
    {cost, value, rate} =
      Enum.reduce(Map.values(assets), {0.0, 0.0, 0}, fn s, {cost, value, _rate} ->
        cost = cost + s.cost
        value = value + s.value
        rate = (value - cost) / cost * 100

        {cost, value, rate}
      end)

    %Portfolio{
      p
      | cost: cost |> round_ceil,
        value: value |> round_ceil,
        rate: rate |> round_ceil
    }
  end
end
