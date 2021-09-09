defmodule Portfolio do
  import Util

  defstruct id: "",
            stocks: %{},
            cost: 0.0,
            value: 0.0,
            rate: 0.0,
            alerts: [],
            last_update_time: nil

  @type t :: %Portfolio{
          id: String.t(),
          stocks: map(),
          cost: float(),
          value: float(),
          rate: float(),
          alerts: [Alert.t()],
          last_update_time: any()
        }

  def new(id), do: %Portfolio{id: id}

  def get_stock_by_order(%Portfolio{stocks: stocks}) do
    Map.values(stocks)
    |> Enum.sort(&(&1.rate >= &2.rate))
  end

  @spec add_stock(Portfolio.t(), Stock.t()) :: Portfolio.t()
  def add_stock(%Portfolio{} = portfolio, %Stock{} = new_stock) do
    Map.put(portfolio, :stocks, Map.put(portfolio.stocks, new_stock.name, new_stock))
    |> calculate()
  end

  @spec remove_stock(Portfolio.t(), String.t()) :: Portfolio.t()
  def remove_stock(%Portfolio{} = portfolio, stock_id) do
    Map.put(portfolio, :stocks, Map.delete(portfolio.stocks, stock_id))
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
  def remove_alert(%Portfolio{alerts: current_alerts} = p, stock_name) do
    %Portfolio{
      p
      | alerts: current_alerts |> Enum.filter(&(&1.stock_name != stock_name))
    }
  end

  @spec update(Portfolio.t(), map()) :: Portfolio.t()
  def update(%Portfolio{} = portfolio, new_stocks) do
    Map.put(portfolio, :stocks, new_stocks)
    |> calculate()
    |> Map.put(:update_time, current_time())
  end

  defp calculate(%Portfolio{stocks: stocks} = p) do
    {cost, value, rate} =
      Enum.reduce(Map.values(stocks), {0.0, 0.0, 0}, fn s, {cost, value, _rate} ->
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
