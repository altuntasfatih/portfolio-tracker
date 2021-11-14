defmodule PortfolioTracker.View do
  @messages_path "./lib/view/messages"

  @spec to_str(
          %{:__struct__ => Portfolio | Asset, :rate => any, :value => any, optional(any) => any},
          :long | :short
        ) :: <<_::64, _::_*8>>
  def to_str(%Asset{} = a, :short) do
    File.read!(@messages_path <> "/asset_sort.mustache")
    |> Mustache.render(%{
      name: a.name,
      value: a.value,
      rate: Util.rate(a.rate)
    })
  end

  def to_str(%Asset{} = a, :long) do
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

  def to_str(%Portfolio{} = p, :short) do
    File.read!(@messages_path <> "/portfolio_short.mustache")
    |> Mustache.render(%{
      value: p.value,
      rate: Util.rate(p.rate),
      time: p.time
    })
  end

  def to_str(%Portfolio{} = p, :long) do
    File.read!("./lib/view/messages/portfolio_long.mustache")
    |> Mustache.render(%{
      value: p.value,
      cost: p.cost,
      rate: Util.rate(p.rate),
      lime: p.time,
      assets:
        Enum.reduce(get_assets(p), "", fn alert, acc ->
          acc <> to_str(alert, :long) <> "\n"
        end)
    })
  end

  def to_str(%Portfolio{} = p), do: to_str(p, :long)

  def to_str(%Alert{} = alert) do
    File.read!(@messages_path <> "/alert.mustache")
    |> Mustache.render(%{
      name: alert.asset_name,
      type: Atom.to_string(alert.type),
      target: alert.price
    })
  end

  def to_str([]), do: "Empty"

  def to_str([alert | _] = alerts) when is_struct(alert, Alert) do
    File.read!(@messages_path <> "/alerts.mustache")
    |> Mustache.render(%{
      alerts:
        Enum.reduce(alerts, "", fn alert, acc ->
          acc <> to_str(alert) <> "\n\n"
        end)
    })
  end

  def to_str(:help) do
    File.read!(@messages_path <> "/help.mustache")
    |> Mustache.render()
  end

  def to_str([:crypto, :bist]) do
    File.read!(@messages_path <> "/asset_types.mustache")
    |> Mustache.render()
  end

  def to_str({:error, :portfolio_not_found}),
    do: "There is no portfolio tracker for you, You should create firstly"

  def to_str({:error, :portfolio_already_created}),
    do: "Your portfolio tracker have already created"

  def to_str({:ok, :portfolio_created}), do: "Portfolio tracker was created for you"

  def to_str({:error, :missing_parameter}),
    do: "Argumet/Arguments are missing"

  def to_str({:error, :args_parse_error}),
    do: "Argumet/Arguments formats are invalid"

  def to_str({:error, :instruction_not_found}),
    do: "Instruction does not exist"

  def to_str({:ok, reply}), do: reply

  def to_str(r), do: r

  defp get_assets(%Portfolio{assets: assets}) do
    Map.values(assets)
    |> Enum.sort(&(&1.rate >= &2.rate))
  end
end
