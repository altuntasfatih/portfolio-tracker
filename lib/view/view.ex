defmodule PortfolioTracker.View do
  @line_break " \n------------------------------------- \n"

  @spec to_string(
          %{:__struct__ => Portfolio | Asset, :rate => any, :value => any, optional(any) => any},
          :long | :short
        ) :: <<_::64, _::_*8>>
  def to_string(%Asset{} = asset, :short) do
    "Name: #{asset.name} \nValue: #{asset.value} \nRate: #{Util.rate(asset.rate)}"
  end

  def to_string(%Asset{} = asset, :long) do
    "Name: #{asset.name} \nTotal: #{asset.total} \nValue: #{asset.value} \nCost price: #{
      asset.cost_price
    } \nPrice: #{asset.price} \nRate: #{Util.rate(asset.rate)}"
  end

  def to_string(%Portfolio{} = p, :short) do
    "Your Portfolio  \nValue: #{p.value} \nUpdate Time: #{p.last_update_time} \nRate: #{
      Util.rate(p.rate)
    }"
  end

  def to_string(%Portfolio{} = p, :long) do
    assets =
      Enum.reduce(get_assets(p), "", fn s, acc ->
        acc <> @line_break <> to_string(s, :long)
      end)

    "Your Portfolio \nCost: #{p.cost} \nValue: #{p.value} \nUpdate Time: #{p.last_update_time} \nRate: #{
      Util.rate(p.rate)
    } #{assets}"
  end

  def to_string(%Portfolio{} = p), do: to_string(p, :long)

  def to_string(%Alert{} = alert) do
    "For #{alert.asset_name} #{Atom.to_string(alert.type)} on #{alert.price} "
  end

  def to_string([]), do: {:ok, "Empty"}

  def to_string([alert | _] = alerts) when is_struct(alert, Alert) do
    "Alerts: \n" <>
      Enum.reduce(alerts, "", fn alert, acc ->
        acc <> "For #{alert.asset_name} #{Atom.to_string(alert.type)} on #{alert.price} \n"
      end)
  end

  def to_string([:crypto, :bist]),
    do: ":crypto -> Crypto Currency \n" <> ":bist -> The Borsa Istanbul Stock"

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

  defp get_assets(%Portfolio{assets: assets}) do
    Map.values(assets)
    |> Enum.sort(&(&1.rate >= &2.rate))
  end
end
