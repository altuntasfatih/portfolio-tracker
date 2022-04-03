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
    assert get(pid) == @portfolio
  end

  test "it should handle add_asset message with crypto asset", %{pid: pid} do
    PortfolioTracker.CryptoMock
    |> expect(:look_up, fn "bitcoin" -> {:ok, "btc"} end)

    asset = Asset.new("btc", "bitcoin", :crypto, 66, 18.20)

    assert add(pid, asset) == :ok

    assert get(pid).assets ==
             %{
               "bitcoin" => %Asset{
                 id: "btc",
                 name: "bitcoin",
                 cost: 1201.21,
                 cost_price: 18.2,
                 price: 18.2,
                 rate: 0.0,
                 total: 66,
                 type: :crypto,
                 value: 1201.21
               }
             }
  end

  test "it should handle delete_asset mesage", %{pid: pid} do
    asset = add_crpto_asset(pid, {"avalanche", "avax", 66, 18.20})

    assert delete(pid, asset.name) == :ok
    assert get(pid) == @portfolio
  end

  test "it should handle live message", %{pid: pid} do
    asset = add_crpto_asset(pid, {"avalanche", "avax", 5, 20})
    asset1 = add_crpto_asset(pid, {"bitcoin", "btc", 10, 10_000})

    PortfolioTracker.CryptoMock
    |> expect(:look_up, fn "avalanche" -> {:ok, "avax"} end)
    |> expect(:look_up, fn "bitcoin" -> {:ok, "btc"} end)

    PortfolioTracker.CryptoMock
    |> expect(:get_price, fn ["avax", "btc"] ->
      {:ok,
       %{
         "btc" => %{name: "btc", currency: "usd", price: 40_000},
         "avax" => %{name: "avax", currency: "usd", price: 85.00}
       }}
    end)

    assert add(pid, asset) == :ok
    assert add(pid, asset1) == :ok
    assert live(pid) == :ok

    portfolio = get(pid)

    assert portfolio.assets == %{
             "avalanche" => %Asset{
               cost: 100.0,
               cost_price: 20.0,
               id: "avax",
               name: "avalanche",
               price: 85.0,
               rate: 325.0,
               total: 5,
               type: :crypto,
               value: 425.0
             },
             "bitcoin" => %Asset{
               cost: 1.0e5,
               cost_price: 1.0e4,
               id: "btc",
               name: "bitcoin",
               price: 40_000,
               rate: 300.0,
               total: 10,
               type: :crypto,
               value: 4.0e5
             }
           }

    assert portfolio.value == 400_425.0
  end

  test "it should handle add_alert message", %{pid: pid} do
    alert = Alert.new(:lower_limit, "xrp", :crypto, 16.0)

    add_alert(pid, alert)
    assert get_alerts(pid) == [alert]
  end

  test "it should handle delete_alert message", %{pid: pid} do
    alert = Alert.new(:lower_limit, "eth", :crypto, 16.0)

    add_alert(pid, alert)
    assert remove_alert(pid, alert.asset_id) == :ok
    assert get_alerts(pid) == []
  end

  test "it should handle check alerts message", %{pid: pid} do
    [Alert.new(:lower_limit, "avax", :crypto, 100), Alert.new(:upper_limit, "btc", :crypto, 600)]
    |> Enum.each(&add_alert(pid, &1))

    not_hit_alerts =
      [
        Alert.new(:lower_limit, "xrp", :crypto, 190),
        Alert.new(:upper_limit, "eth", :crypto, 20_000)
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
    assert get_alerts(pid) == not_hit_alerts
  end

  defp get(pid), do: GenServer.call(pid, :get)
  defp add(pid, new_asset), do: GenServer.cast(pid, {:add_asset, new_asset})
  defp live(pid), do: GenServer.cast(pid, :live)

  defp remove_alert(pid, asset_name), do: GenServer.cast(pid, {:remove_alert, asset_name})
  defp get_alerts(pid), do: GenServer.call(pid, :get_alerts)
  defp delete(pid, asset_name), do: GenServer.cast(pid, {:delete_asset, asset_name})

  defp add_alert(pid, alert) do
    assert GenServer.cast(pid, {:set_alert, alert}) == :ok
  end

  defp add_crpto_asset(pid, {name, id, count, price}) do
    asset = Asset.new(name, :crypto, count, price)

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
