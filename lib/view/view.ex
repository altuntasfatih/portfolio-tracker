defmodule PortfolioTracker.View do
  @messages_path "./lib/view/messages"
  @line_break " \n------------------------------------- \n"

  @spec to_string(
          %{:__struct__ => Portfolio | Asset, :rate => any, :value => any, optional(any) => any},
          :long | :short
        ) :: <<_::64, _::_*8>>
  def to_string(%Asset{} = a, :short) do
    File.read!(@messages_path <> "/asset_sort.mustache")
    |> Mustache.render(%{
      name: a.name,
      value: a.value,
      rate: Util.rate(a.rate)
    })
  end

  def to_string(%Asset{} = a, :long) do
    File.read!(@messages_path <> "/asset_long.mustache")
    |> Mustache.render(%{
      name: a.name,
      total: a.total,
      value: a.value,
      costPrice: a.cost_price,
      price: a.price,
      rate: Util.rate(a.rate)
    })
  end

  def to_string(%Portfolio{} = p, :short) do
    File.read!("./lib/view/messages/portfolio_short.mustache")
    |> Mustache.render(%{
      value: p.value,
      rate: Util.rate(p.rate),
      lastUpdateTime: p.last_update_time
    })
  end

  def to_string(%Portfolio{} = p, :long) do
    assets =
      get_assets(p)
      |> Enum.map(fn a ->
        %{
          name: a.name,
          total: a.total,
          value: a.value,
          costPrice: a.cost_price,
          price: a.price,
          rate: Util.rate(a.rate)
        }
      end)

    File.read!("./lib/view/messages/portfolio_long.mustache")
    |> Mustache.render(%{
      value: p.value,
      cost: p.cost,
      rate: Util.rate(p.rate),
      lastUpdateTime: p.last_update_time,
      assets: assets
    })
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

  def to_string(:help) do
    File.read!("./lib/view/messages/help.mustache")
    |> Mustache.render()
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
