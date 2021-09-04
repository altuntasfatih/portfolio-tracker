defmodule PortfolioTracker.TrackerTest do
  use ExUnit.Case
  alias PortfolioTracker.Tracker

  @portfolio Portfolio.new("1")

  setup_all do
    {:ok, _} = PortfolioTracker.MockExchangeApi.start_link()
    :ok
  end

  setup do
    {:ok, pid} = GenServer.start_link(Tracker, @portfolio)
    on_exit(fn -> Process.exit(pid, :normal) end)
    {:ok, pid: pid}
  end

  test "it should get portfolio", %{pid: pid} do
    assert get(pid) == @portfolio
  end

  test "it should add stock to portfolio", %{pid: pid} do
    stock = Stock.new("AVISA", "avivasa", 66, 18.20)
    assert add(pid, stock) == :ok

    assert get(pid) == @portfolio |> Portfolio.add_stock(stock)
  end

  test "it should delete stock from portfolio", %{pid: pid} do
    stock = Stock.new("AVISA", "avivasa", 66, 18.20)
    assert add(pid, stock) == :ok

    assert delete(pid, stock.id) == :ok
    assert get(pid) == @portfolio
  end

  test "it should update stocks with live prices", %{pid: pid} do
    stock = Stock.new("AVISA", "AvivaSA", 10, 10)
    stock2 = Stock.new("TUPRS", "Turkiye Petrol ", 5, 5.00)

    assert add(pid, stock) == :ok
    assert add(pid, stock2) == :ok

    PortfolioTracker.MockExchangeApi.push([
      %{name: "AVISA", price: 15.00},
      %{name: "TUPRS", price: 5.00}
    ])

    assert update(pid) == :ok

    portfolio = get(pid)

    assert portfolio.stocks == %{
             "AVISA" => Stock.update(stock, 15.00),
             "TUPRS" => Stock.update(stock2, 5)
           }

    assert portfolio.cost == 125.0
    assert portfolio.value == 175.0
    assert portfolio.rate == 40.0
    assert portfolio.update_time != nil
  end

  test "it should update stocks price", _ do
    stock = Stock.new("AVISA", "AvivaSA", 66, 18.20)
    stock2 = Stock.new("TUPRS", "Turkiye Petrol ", 10, 110.22)

    current_prices = [%{name: "AVISA", price: 19.33}, %{name: "TUPRS", price: 102.60}]

    assert Tracker.update_stocks_with_live([stock2, stock], current_prices) == [
             Stock.update(stock2, 102.60),
             Stock.update(stock, 19.33)
           ]
  end

  test "it should add_alert for stock", %{pid: pid} do
    alert = Alert.new(:lower_limit, "AVISA", 16.0)
    assert set_alert(pid, alert) == :ok
    assert get_alerts(pid) == [alert]
  end

  test "it should delete alert", %{pid: pid} do
    alert = Alert.new(:lower_limit, "AVISA", 16.0)
    assert set_alert(pid, alert) == :ok
    assert remove_alert(pid, alert.stock_name) == :ok
    assert get_alerts(pid) == []
  end

  test "it should check alerts condition", _ do
    alert = Alert.new(:lower_limit, "AVISA", 16.0)
    alert2 = Alert.new(:lower_limit, "TUPRS", 100.0)
    alert3 = Alert.new(:upper_limit, "KRDMD", 50.0)

    PortfolioTracker.MockExchangeApi.push([
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

    PortfolioTracker.MockExchangeApi.push([
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

  def add(pid, new_stock) do
    GenServer.cast(pid, {:add_stock, new_stock})
  end

  def set_alert(pid, alert) do
    GenServer.cast(pid, {:set_alert, alert})
  end

  def remove_alert(pid, stock_id) do
    GenServer.cast(pid, {:remove_alert, stock_id})
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

  def delete(pid, stock_id) do
    GenServer.cast(pid, {:delete_stock, stock_id})
  end

  def update(pid) do
    GenServer.cast(pid, :update)
  end
end
