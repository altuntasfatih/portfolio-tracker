defmodule Portfolio do
  import Util

  defstruct id: "",
            stocks: %{},
            total_cost: 0.0,
            total_worth: 0.0,
            rate: 0.0,
            update_time: nil,
            alerts: []

  @line_break " \n------------------------------------- \n"

  def new(id) do
    %Portfolio{id: id}
  end

  def get_stocks(%Portfolio{stocks: stocks}) do
    Map.values(stocks)
    |> Enum.sort(&(&1.rate >= &2.rate))
  end

  def add_stock(%Portfolio{} = portfolio, %Stock{} = new_stock) do
    Map.put(portfolio, :stocks, Map.put(portfolio.stocks, new_stock.id, new_stock))
    |> calculate()
  end

  def delete_stock(%Portfolio{} = portfolio, stock_id) do
    Map.put(portfolio, :stocks, Map.delete(portfolio.stocks, stock_id))
    |> calculate()
  end

  def add_alert(%Portfolio{alerts: current_alerts} = p, %Alert{} = alert) do
    %Portfolio{
      p
      | alerts: [alert | current_alerts] |> Enum.reverse()
    }
  end

  def update(%Portfolio{} = portfolio, new_stocks) do
    Map.put(portfolio, :stocks, new_stocks)
    |> calculate()
    |> Map.put(:update_time, current_time())
  end

  defp calculate(%Portfolio{stocks: stocks, id: id, update_time: time}) do
    Map.values(stocks)
    |> Enum.reduce(new(id), fn s, acc ->
      cost = (acc.total_cost + s.total_cost) |> round_()
      worth = (acc.total_worth + s.current_worth) |> round_()

      %Portfolio{
        acc
        | total_cost: cost,
          total_worth: worth,
          rate: ((worth - cost) / cost * 100) |> round_ceil
      }
    end)
    |> Map.put(:stocks, stocks)
    |> Map.put(:update_time, time)
  end

  def to_string(%Portfolio{} = p) do
    "Your Portfolio  \nWorth: #{p.total_worth} \nUpdate Time: #{p.update_time} \nRate: #{
      rate(p.rate)
    }"
  end

  def detailed_to_string(%Portfolio{} = p) do
    stocks =
      Enum.reduce(get_stocks(p), "", fn s, acc ->
        acc <> @line_break <> Stock.detailed_to_string(s)
      end)

    "Your Portfolio \nCost: #{p.total_cost} \nWorth: #{p.total_worth} \nUpdate Time: #{
      p.update_time
    } \nRate: #{rate(p.rate)} #{stocks}"
  end
end
