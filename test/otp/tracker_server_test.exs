defmodule PortfolioTracker.ServerTest do
  use ExUnit.Case
  alias PortfolioTracker.Server

  @portfolio Portfolio.new("1")

  setup do
    {:ok, _} = PortfolioTracker.MockExchangeApi.start_link()
    {:ok, pid} = GenServer.start_link(Server, @portfolio)
    {:ok, pid: pid}
  end

  test "it_should_get_portfolio", %{pid: pid} do
    assert get(pid) == @portfolio
  end

  test "it_should_add_stock_to_portfolio", %{pid: pid} do
    stock = Stock.new("AVISA", "avivasa", 66, 18.20)
    assert add(pid, stock) == :ok

    assert get(pid) == %{
             @portfolio
             | stocks: %{
                 "AVISA" => stock
               },
               total_cost: stock.total_cost,
               total_worth: stock.current_worth
           }
  end

  test "it_should_delete_stock_from_portfolio", %{pid: pid} do
    stock = Stock.new("AVISA", "avivasa", 66, 18.20)
    assert add(pid, stock) == :ok

    assert delete(pid, stock.id) == :ok
    assert get(pid) == @portfolio
  end

  test "it_should_update_stocks_with_live_prices", %{pid: pid} do
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
             "AVISA" => Stock.calculate(stock, 15.00),
             "TUPRS" => Stock.calculate(stock2, 5)
           }

    assert portfolio.total_cost == 125.0
    assert portfolio.total_worth == 175.0
    assert portfolio.rate == 40.0
    assert portfolio.update_time != nil
  end

  test "it_should_update_stocks_price", _ do
    stock = Stock.new("AVISA", "AvivaSA", 66, 18.20)
    stock2 = Stock.new("TUPRS", "Turkiye Petrol ", 10, 110.22)

    current_prices = [%{name: "AVISA", price: 19.33}, %{name: "TUPRS", price: 102.60}]

    assert Server.update_stocks_with_live([stock2, stock], current_prices) == [
             Stock.calculate(stock2, 102.60),
             Stock.calculate(stock, 19.33)
           ]
  end

  test "it_should_add_alert_for_stock", %{pid: pid} do
    alert = Alert.new(:lower_limit, "AVISA", 16.0)
    assert set_alert(pid, alert) == :ok

    assert get_alerts(pid) == [alert]
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
