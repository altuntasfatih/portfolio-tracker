defmodule PortfolioTracker.View do
  @line_break " \n------------------------------------- \n"

  def to_string(%Stock{} = stock, :short) do
    "Name: #{stock.id} \nValue: #{stock.value} \nRate: #{Util.rate(stock.rate)}"
  end

  def to_string(%Stock{} = stock, :long) do
    "Name: #{stock.id} \nTotal: #{stock.total} \nCost price: #{stock.cost_price} \nCost: #{
      stock.cost
    } \nPrice: #{stock.price} \nValue: #{stock.value} \nRate: #{Util.rate(stock.rate)}"
  end

  def to_string(%Portfolio{} = p, :short) do
    "Your Portfolio  \nValue: #{p.value} \nUpdate Time: #{p.last_update_time} \nRate: #{
      Util.rate(p.rate)
    }"
  end

  def to_string(%Portfolio{} = p, :long) do
    stocks =
      Enum.reduce(get_stocks(p), "", fn s, acc ->
        acc <> @line_break <> to_string(s, :long)
      end)

    "Your Portfolio \nCost: #{p.cost} \nValue: #{p.value} \nUpdate Time: #{p.last_update_time} \nRate: #{
      Util.rate(p.rate)
    } #{stocks}"
  end

  def to_string(%Alert{} = alert) do
    "For #{alert.stock_name} #{Atom.to_string(alert.type)} on #{alert.price} "
  end

  def to_string([]), do: {:ok, "Empty"}

  def to_string({:error, :portfolio_not_found}),
    do: "There is no portfolio tracker for you, You should create firstly"

  def to_string({:error, :portfolio_already_created}),
    do: "Your portfolio tracker have already created"

  def to_string({:ok, :portfolio_created}), do: "Portfolio tracker was created for you"

  def to_string({:error, :missing_parameter}),
    do: "Argumet/Arguments are missing"

  def to_string({:error, :args_parse_error}),
    do: "Argumet/Arguments formats are invalid"

  def to_string({:error, :instruction_not_found}),
    do: "Instruction does not exist"

  def to_string({:ok, reply}), do: reply

  def to_string(r), do: r

  defp get_stocks(%Portfolio{stocks: stocks}) do
    Map.values(stocks)
    |> Enum.sort(&(&1.rate >= &2.rate))
  end
end
