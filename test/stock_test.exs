defmodule StockTest do
  use ExUnit.Case

  @id "Test"
  @name "Test Market"

  test "it_should_create_stock" do
    assert Stock.new(@id, @name, 100, 10) == %Stock{
             id: @id,
             name: @name,
             count: 100,
             total_cost: 1000.0
           }
  end

  test "it_should_calculate_stock_value, " do
    new_price = 13.41

    assert Stock.new(@id, @name, 100, 10) |> Stock.calculate(new_price) == %Stock{
             id: @id,
             name: @name,
             count: 100,
             total_cost: 1000.0,
             current_price: new_price,
             current_worth: 1341.0,
             rate: 34.11
           }
  end

  test "it_should_calculate_stock_value_when_rate_is_negative " do
    new_price = 8.57

    assert Stock.new(@id, @name, 100, 10) |> Stock.calculate(new_price) == %Stock{
             id: @id,
             name: @name,
             count: 100,
             total_cost: 1000.0,
             current_price: new_price,
             current_worth: 857.0,
             rate: -14.29
           }
  end
end
