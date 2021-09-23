defmodule PortfolioTracker.TrackerTest do
  use ExUnit.Case
  alias PortfolioTracker.{Bist.MockApi, Tracker}

  @portfolio Portfolio.new("1")

  setup do
    {:ok, mock_api} = MockApi.start_link()
    {:ok, pid} = GenServer.start_link(Tracker, @portfolio)
    on_exit(fn -> Process.exit(pid, :normal) end)
    on_exit(fn -> MockApi.stop(mock_api) end)
    {:ok, pid: pid}
  end

  test "it should get portfolio", %{pid: pid} do
    assert get(pid) == @portfolio
  end

  test "it should add asset to portfolio", %{pid: pid} do
    asset = Asset.new("AVISA", "bist", 66, 18.20)
    assert add(pid, asset) == :ok

    assert get(pid) == @portfolio |> Portfolio.add_asset(asset)
  end

  test "it should delete asset from portfolio", %{pid: pid} do
    asset = Asset.new("AVISA", "bist", 66, 18.20)
    assert add(pid, asset) == :ok

    assert delete(pid, asset.name) == :ok
    assert get(pid) == @portfolio
  end

  @tag :pending
  test "it should update assets price", _ do
    # asset = Asset.new("AVISA", "bist", 66, 18.20)
    # asset2 = Asset.new("TUPRS", "bist", 10, 110.22)

    # current_prices = [%{name: "AVISA", price: 19.33}, %{name: "TUPRS", price: 102.60}]

    # assert Tracker.update_assets_with_live([asset2, asset], current_prices) == [
    #         Asset.update(asset2, 102.60),
    #         Asset.update(asset, 19.33)
    #       ]
  end

  test "it should add_alert for asset", %{pid: pid} do
    alert = Alert.new(:lower_limit, "AVISA", 16.0)
    assert set_alert(pid, alert) == :ok
    assert get_alerts(pid) == [alert]
  end

  test "it should delete alert", %{pid: pid} do
    alert = Alert.new(:lower_limit, "AVISA", 16.0)
    assert set_alert(pid, alert) == :ok
    assert remove_alert(pid, alert.asset_name) == :ok
    assert get_alerts(pid) == []
  end

  test "it should split alerts by condition hit", _ do
    alert = Alert.new(:lower_limit, "AVISA", 16.0)
    alert2 = Alert.new(:lower_limit, "TUPRS", 100.0)
    alert3 = Alert.new(:upper_limit, "KRDMD", 50.0)

    MockApi.push([
      %{name: "AVISA", price: 15.33},
      %{name: "TUPRS", price: 120.60},
      %{name: "KRDMD", price: 20.60},
      %{name: "CANTE", price: 120.60}
    ])

    assert Tracker.check_alerts_condition([alert, alert2, alert3]) == {[alert], [alert2, alert3]}
  end

  test "it should handle check alerts message", %{pid: pid} do
    hit_alert = Alert.new(:lower_limit, "AVISA", 16.0)
    not_hit_alert_ = Alert.new(:lower_limit, "TUPRS", 100.0)
    not_hit_alert_2 = Alert.new(:upper_limit, "KRDMD", 50.0)

    assert set_alert(pid, hit_alert) == :ok
    assert set_alert(pid, not_hit_alert_) == :ok
    assert set_alert(pid, not_hit_alert_2) == :ok

    MockApi.push([
      %{name: "AVISA", price: 15.33},
      %{name: "TUPRS", price: 120.60},
      %{name: "KRDMD", price: 20.60},
      %{name: "CANTE", price: 120.60}
    ])

    assert check_alerts(pid) == :ok
    assert get_alerts(pid) == [not_hit_alert_, not_hit_alert_2]
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def add(pid, new_asset) do
    GenServer.cast(pid, {:add_asset, new_asset})
  end

  def set_alert(pid, alert) do
    GenServer.cast(pid, {:set_alert, alert})
  end

  def remove_alert(pid, asset_name) do
    GenServer.cast(pid, {:remove_alert, asset_name})
  end

  def check_alerts(pid) do
    case send(pid, :check_alert) do
      :check_alert -> :ok
      m -> m
    end
  end

  def get_alerts(pid) do
    GenServer.call(pid, :get_alerts)
  end

  def delete(pid, asset_name) do
    GenServer.cast(pid, {:delete_asset, asset_name})
  end

  def update(pid) do
    GenServer.cast(pid, :update)
  end
end
