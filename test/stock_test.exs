defmodule StockTest do
  use ExUnit.Case

  @id "Test"
  @name "Test Market"
  @target_price 20.0

  test "it_should_create_stock" do
    assert Stock.new(@id, @name, 100, 10.0, @target_price) == %Stock{
             id: @id,
             name: @name,
             count: 100,
             current_price: 10.0,
             current_worth: 1000.0,
             rate: 0.0,
             total_cost: 1000.0,
             target_price: @target_price
           }
  end

  test "it_should_calculate_stock_value, " do
    new_price = 13.41

    assert Stock.new(@id, @name, 100, 10, @target_price) |> Stock.calculate(new_price) == %Stock{
             id: @id,
             name: @name,
             count: 100,
             total_cost: 1000.0,
             current_price: new_price,
             current_worth: 1341.0,
             target_price: @target_price,
             rate: 34.11
           }
  end

  test "it_should_calculate_stock_value_when_rate_is_negative " do
    new_price = 8.57

    assert Stock.new(@id, @name, 100, 10, @target_price) |> Stock.calculate(new_price) == %Stock{
             id: @id,
             name: @name,
             count: 100,
             total_cost: 1000.0,
             current_price: new_price,
             current_worth: 857.0,
             rate: -14.29,
             target_price: @target_price
           }
  end
end
