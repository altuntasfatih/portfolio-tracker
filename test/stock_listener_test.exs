defmodule StockListenerTest do
  use ExUnit.Case
  doctest StockListener

  @portfolio %StockPortfolio{id: "1", rate: 0.0, stocks: [], total_cost: 0.0, total_worth: 0.0}

  setup do
    {:ok, _} = StockListener.MockStockApi.start_link()
    {:ok, pid} = GenServer.start_link(StockListener, @portfolio)
    {:ok, pid: pid}
  end

  test "it_should_get_state_of_portfolio", %{pid: pid} do
    assert get(pid) == @portfolio
  end

  test "it_should_add_stock_to_portfolio", %{pid: pid} do
    stock = Stock.new("AVISA", "avivasa", 66, 18.20, 25.00)
    assert add(pid, stock) == :ok

    assert get(pid) == %{
             @portfolio
             | stocks: [stock],
               total_cost: stock.total_cost,
               total_worth: stock.current_worth
           }
  end

  test "it_should_delete_stock_from_portfolio", %{pid: pid} do
    stock = Stock.new("AVISA", "avivasa", 66, 18.20, 25.00)
    assert add(pid, stock) == :ok
    assert delete(pid, stock.id) == :ok

    assert get(pid) == @portfolio
  end

  test "it_should_update_portfolio", %{pid: pid} do
    stock = Stock.new("AVISA", "AvivaSA", 66, 18.20, 25.00)
    stock2 = Stock.new("TUPRS", "Turkiye Petrol ", 10, 110.22, 149.00)
    assert add(pid, stock) == :ok
    assert add(pid, stock2) == :ok

    stock = stock |> Stock.calculate(19.33)
    stock2 = stock2 |> Stock.calculate(102.60)

    assert update_stocks(pid, [stock2, stock]) == :ok

    assert get(pid) == %{
             @portfolio
             | stocks: [stock, stock2],
               total_cost: 2303.42,
               total_worth: 2301.78,
               rate: -0.07
           }
  end

  test "it_should_update_stock_prices", _ do
    stock = Stock.new("AVISA", "AvivaSA", 66, 18.20, 25.00)
    stock2 = Stock.new("TUPRS", "Turkiye Petrol ", 10, 110.22, 149.00)

    current_prices = [%{name: "AVISA", price: 19.33}, %{name: "TUPRS", price: 102.60}]

    assert StockListener.update_stock_prices([stock2, stock], current_prices) == [
             Stock.calculate(stock2, 102.60),
             Stock.calculate(stock, 19.33)
           ]
  end

  test "it_should_update_stock_prices_live_prices", %{pid: pid} do
    stock = Stock.new("AVISA", "AvivaSA", 10, 10, 20.00)
    stock2 = Stock.new("TUPRS", "Turkiye Petrol ", 5, 5.00, 7.00)

    assert add(pid, stock) == :ok
    assert add(pid, stock2) == :ok

    StockListener.MockStockApi.push([
      %{name: "AVISA", price: 15.00},
      %{name: "TUPRS", price: 5.00}
    ])

    assert update_prices(pid) == :ok

    assert get(pid) == %{
             @portfolio
             | stocks: [Stock.calculate(stock2, 5), Stock.calculate(stock, 15.00)],
               total_cost: 125.0,
               total_worth: 175.0,
               rate: 40.0
           }
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def add(pid, new_stock) do
    GenServer.cast(pid, {:add_stock, new_stock})
  end

  def delete(pid, stock_id) do
    GenServer.cast(pid, {:delete_stock, stock_id})
  end

  def update_prices(pid) do
    GenServer.cast(pid, :update_prices)
  end

  def update_stocks(pid, stocks) do
    GenServer.cast(pid, {:update_stocks, stocks})
  end
end
