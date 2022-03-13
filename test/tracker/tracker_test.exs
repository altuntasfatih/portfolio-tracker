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
    allow(PortfolioTracker.BistMock, self(), pid)
    {:ok, pid: pid}
  end

  test "it should handle get message", %{pid: pid} do
    assert get(pid) == @portfolio
  end

  test "it should handle add_asset message with bist asset", %{pid: pid} do
    asset = Asset.new("AVISA", :bist, 66, 18.20)
    assert add(pid, asset) == :ok

    assert get(pid) == @portfolio |> Portfolio.add_asset(asset)
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
    asset = Asset.new("AVISA", :bist, 66, 18.20)
    assert add(pid, asset) == :ok

    assert delete(pid, asset.name) == :ok
    assert get(pid) == @portfolio
  end

  test "it should handle live message", %{pid: pid} do
    asset = Asset.new("AVISA", :bist, 10, 10.0)
    asset1 = Asset.new("TUPRS", :bist, 10, 10.0)
    asset2 = Asset.new("bitcoin", :crypto, 10, 10.0)

    PortfolioTracker.BistMock
    |> expect(:get_price, fn ["AVISA", "TUPRS"] ->
      {:ok,
       %{"AVISA" => %{name: "AVISA", price: 11.00}, "TUPRS" => %{name: "TUPRS", price: 12.00}}}
    end)

    PortfolioTracker.CryptoMock
    |> expect(:look_up, fn "bitcoin" -> {:ok, "btc"} end)

    PortfolioTracker.CryptoMock
    |> expect(:get_price, fn ["btc"] ->
      {:ok, %{"btc" => %{name: "btc", currency: "usd", price: 11.00}}}
    end)

    assert add(pid, asset) == :ok
    assert add(pid, asset1) == :ok
    assert add(pid, asset2) == :ok
    assert live(pid) == :ok

    portfolio = get(pid)

    assert portfolio.assets == %{
             "AVISA" => %Asset{
               id: "AVISA",
               name: "AVISA",
               cost: 100.0,
               cost_price: 10.0,
               price: 11.0,
               rate: 10.0,
               total: 10,
               type: :bist,
               value: 110.0
             },
             "TUPRS" => %Asset{
               id: "TUPRS",
               name: "TUPRS",
               cost: 100.0,
               cost_price: 10.0,
               price: 12.0,
               rate: 20.0,
               total: 10,
               type: :bist,
               value: 120.0
             },
             "bitcoin" => %Asset{
               id: "btc",
               name: "bitcoin",
               cost: 100.0,
               cost_price: 10.0,
               price: 11.0,
               rate: 10.0,
               total: 10,
               type: :crypto,
               value: 110.0
             }
           }

    assert portfolio.value == 340.0
  end

  test "it should handle add_alert message", %{pid: pid} do
    alert = Alert.new(:lower_limit, "AVISA", :bist, 16.0)
    assert set_alert(pid, alert) == :ok
    assert get_alerts(pid) == [alert]
  end

  test "it should handle delete_alert message", %{pid: pid} do
    alert = Alert.new(:lower_limit, "AVISA", :bist, 16.0)
    assert set_alert(pid, alert) == :ok
    assert remove_alert(pid, alert.asset_name) == :ok
    assert get_alerts(pid) == []
  end

  test "it should handle check alerts message", %{pid: pid} do
    hit_alert = Alert.new(:lower_limit, "AVISA", :bist, 16.0)
    hit_alert_2 = Alert.new(:lower_limit, "TUPRS", :bist, 100.0)
    hit_alert_3 = Alert.new(:upper_limit, "bitcoin", :crypto, 600.0)
    not_hit_alert = Alert.new(:upper_limit, "KRDMD", :bist, 50.0)
    not_hit_alert2 = Alert.new(:lower_limit, "eth", :crypto, 190.0)

    assert set_alert(pid, hit_alert) == :ok
    assert set_alert(pid, hit_alert_2) == :ok
    assert set_alert(pid, hit_alert_3) == :ok
    assert set_alert(pid, not_hit_alert) == :ok
    assert set_alert(pid, not_hit_alert2) == :ok

    PortfolioTracker.BistMock
    |> expect(:get_price, fn _ ->
      {:ok,
       %{
         "AVISA" => %{name: "AVISA", price: 15.33},
         "TUPRS" => %{name: "TUPRS", price: 90.60},
         "KRDMD" => %{name: "KRDMD", price: 20.60}
       }}
    end)

    PortfolioTracker.CryptoMock
    |> expect(:get_price, fn ["bitcoin", "eth"] ->
      {:ok,
       %{
         "bitcoin" => %{name: "bitcoin", currency: "usd", price: 650.00},
         "eth" => %{name: "eth", currency: "usd", price: 210.00}
       }}
    end)

    assert check_alerts(pid) == :ok
    assert get_alerts(pid) == [not_hit_alert2, not_hit_alert]
  end

  defp get(pid), do: GenServer.call(pid, :get)
  defp add(pid, new_asset), do: GenServer.cast(pid, {:add_asset, new_asset})
  defp live(pid), do: GenServer.cast(pid, :live)
  defp set_alert(pid, alert), do: GenServer.cast(pid, {:set_alert, alert})
  defp remove_alert(pid, asset_name), do: GenServer.cast(pid, {:remove_alert, asset_name})
  defp get_alerts(pid), do: GenServer.call(pid, :get_alerts)
  defp delete(pid, asset_name), do: GenServer.cast(pid, {:delete_asset, asset_name})

  defp check_alerts(pid) do
    case send(pid, :check_alert) do
      :check_alert -> :ok
      e -> e
    end
  end
end
