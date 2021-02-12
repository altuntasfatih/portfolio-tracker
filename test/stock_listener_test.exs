defmodule StockListenerTest do
  use ExUnit.Case
  doctest StockListener

  @portfolio %StockPortfolio{id: "1", rate: 0.0, stocks: [], total_cost: 0.0, total_worth: 0.0}

  setup do
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

  test "it_should_update_portfolio", %{pid: pid} do
    stock = Stock.new("AVISA", "AvivaSA", 66, 18.20, 25.00)
    stock2 = Stock.new("TUPRS", "Turkiye Petrol ", 10, 110.22, 149.00)
    assert add(pid, stock) == :ok
    assert add(pid, stock2) == :ok

    stock= stock |> Stock.calculate(19.33)
    stock2= stock2 |> Stock.calculate(102.60)

    assert update_stocks(pid,[stock2,stock]) == :ok

    assert get(pid) == %{
               @portfolio |
               stocks: [stock, stock2],
               total_cost: 2303.42,
               total_worth: 2301.78,
               rate: -0.07,
           }
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def add(pid, new_stock) do
    GenServer.cast(pid, {:add, new_stock})
  end

  def update_stocks(pid, stocks) do
    GenServer.cast(pid, {:update_stocks, stocks})
  end
end
