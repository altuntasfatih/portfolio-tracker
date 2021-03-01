defmodule StockTest do
  use ExUnit.Case

  @id "Test"
  @name "Test Market"
  @stock_count 100
  @target_price 20.0

  test "it_should_create_stock" do
    assert Stock.new(@id, @name, 100, 10.0, @target_price) == %Stock{
             id: @id,
             name: @name,
             count: @stock_count,
             purchase_price: 10.0,
             total_cost: 1000.0,
             current_price: 10.0,
             current_worth: 1000.0,
             rate: 0.0,
             target_price: @target_price
           }
  end

  test "it_should_calculate_stock_value, " do
    purchase_price = 10.0
    new_price = 13.41

    assert Stock.new(@id, @name, 100, purchase_price, @target_price) |> Stock.calculate(new_price) ==
             %Stock{
               id: @id,
               name: @name,
               count: @stock_count,
               purchase_price: purchase_price,
               total_cost: 1000.0,
               current_price: new_price,
               current_worth: 1341.0,
               target_price: @target_price,
               rate: 34.11
             }
  end

  test "it_should_calculate_stock_value_when_rate_is_negative " do
    purchase_price = 10.0
    new_price = 8.57

    assert Stock.new(@id, @name, 100, 10, @target_price) |> Stock.calculate(new_price) == %Stock{
             id: @id,
             name: @name,
             count: @stock_count,
             purchase_price: purchase_price,
             total_cost: 1000.0,
             current_price: new_price,
             current_worth: 857.0,
             rate: -14.29,
             target_price: @target_price
           }
  end
end
