defmodule PortfolioTracker.TrackerTest do
  use ExUnit.Case, async: false
  alias PortfolioTracker.Tracker
  import Mox

  @portfolio Portfolio.new("1")

  setup :verify_on_exit!

  setup do
    {:ok, pid} = GenServer.start_link(Tracker, @portfolio)
    on_exit(fn -> Process.exit(pid, :normal) end)
    allow(PortfolioTracker.CryptoMock, self(), pid)
    {:ok, pid: pid}
  end

  test "it should handle get message", %{pid: pid} do
    assert {:ok, @portfolio} = get(pid)
  end

  test "it should handle add_asset message with crypto asset", %{pid: pid} do
    # given
    PortfolioTracker.CryptoMock
    |> expect(:look_up, fn "bitcoin" -> {:ok, "btc"} end)

    PortfolioTracker.CryptoMock
    |> expect(:get_price, fn ["btc"] ->
      {:ok,
       %{
         "btc" => %{name: "btc", currency: "usd", price: 50.5}
       }}
    end)

    asset = Asset.new("btc", "bitcoin", 66, 18.20)

    # then
    assert add(pid, asset) == :ok

    assert {:ok, portfolio} = get(pid)

    assert portfolio.assets ==
             %{
               "bitcoin" => %Asset{
                 cost: 1201.21,
                 cost_price: 18.2,
                 id: "btc",
                 name: "bitcoin",
                 price: 50.5,
                 rate: 177.48,
                 total: 66,
                 type: :crypto,
                 value: 3333.0
               }
             }
  end

  test "it should handle delete_asset mesage", %{pid: pid} do
    asset = add_crpto_asset(pid, {"avalanche", "avax", 66, 18.20})

    assert delete(pid, asset.name) == :ok
    assert {:ok, @portfolio} = get(pid)
  end

  test "it should handle add_alert message", %{pid: pid} do
    alert = Alert.new(:lower_limit, "xrp", 16.0)
    add_alert(pid, alert)

    assert get_alerts(pid) == {:ok, [alert]}
  end

  test "it should handle delete_alert message", %{pid: pid} do
    alert = Alert.new(:lower_limit, "eth", 16.0)
    add_alert(pid, alert)

    assert remove_alert(pid, alert.asset_id) == :ok
    assert get_alerts(pid) == {:ok, []}
  end

  test "it should handle check alerts message", %{pid: pid} do
    alerts =
      [
        # not hit alerrs
        Alert.new(:lower_limit, "xrp", 190),
        Alert.new(:upper_limit, "eth", 20_000),
        # hit alerts
        Alert.new(:lower_limit, "avax", 100),
        Alert.new(:upper_limit, "btc", 600)
      ]
      |> tap(fn alerts -> Enum.each(alerts, &add_alert(pid, &1)) end)

    PortfolioTracker.CryptoMock
    |> expect(:get_price, fn [_, _, _, _] ->
      {:ok,
       %{
         "avax" => %{name: "avax", currency: "usd", price: 95},
         "btc" => %{name: "btc", currency: "usd", price: 650},
         "xrp" => %{name: "xrp", currency: "usd", price: 191},
         "eth" => %{name: "eth", currency: "usd", price: 19_550}
       }}
    end)

    assert check_alerts(pid) == :ok
    assert get_alerts(pid) == {:ok, Enum.take(alerts, 2)}
  end

  defp get(pid), do: GenServer.call(pid, :get)
  defp add(pid, new_asset), do: GenServer.cast(pid, {:add_asset, new_asset})

  defp remove_alert(pid, asset_name), do: GenServer.cast(pid, {:remove_alert, asset_name})
  defp get_alerts(pid), do: GenServer.call(pid, :get_alerts)
  defp delete(pid, asset_name), do: GenServer.cast(pid, {:delete_asset, asset_name})

  defp add_alert(pid, alert) do
    assert GenServer.cast(pid, {:set_alert, alert}) == :ok
  end

  defp add_crpto_asset(pid, {name, id, count, price}) do
    asset = Asset.new(name, count, price)

    PortfolioTracker.CryptoMock
    |> expect(:look_up, fn ^name -> {:ok, id} end)

    assert add(pid, asset) == :ok
    asset
  end

  defp check_alerts(pid) do
    case send(pid, :check_alert) do
      :check_alert -> :ok
      e -> e
    end
  end
end
