defmodule StockTest do
  use ExUnit.Case

  @id "Test"
  @name "Test Market"
  @stock_count 100
  @purchase_price 10.0

  test "it_should_create_stock" do
    assert Stock.new(@id, @name, @stock_count, @purchase_price) == %Stock{
             id: @id,
             name: @name,
             count: @stock_count,
             purchase_price: @purchase_price,
             total_cost: 1000.0,
             current_price: 10.0,
             current_worth: 1000.0,
             rate: 0.0
           }
  end

  test "it_should_calculate_stock_value, " do
    new_price = 13.41

    assert Stock.new(@id, @name, @stock_count, @purchase_price) |> Stock.calculate(new_price) ==
             %Stock{
               id: @id,
               name: @name,
               count: @stock_count,
               purchase_price: @purchase_price,
               total_cost: 1000.0,
               current_price: new_price,
               current_worth: 1341.0,
               rate: 34.11
             }
  end

  test "it_should_calculate_stock_value_when_rate_is_negative " do
    new_price = 8.57

    assert Stock.new(@id, @name, @stock_count, @purchase_price) |> Stock.calculate(new_price) ==
             %Stock{
               id: @id,
               name: @name,
               count: @stock_count,
               purchase_price: @purchase_price,
               total_cost: 1000.0,
               current_price: new_price,
               current_worth: 857.0,
               rate: -14.29
             }
  end

  test "it_should_return_string_represantation_of_stock" do
    new_price = 8.57

    assert Stock.new(@id, @name, @stock_count, @purchase_price)
           |> Stock.calculate(new_price)
           |> Stock.to_string() == "Name: Test \nWorth: 857.0 \nRate: -14.29 🔴 "
  end

  test "it_should_return_detailed_string_represantation_of_stock" do
    new_price = 8.57

    assert Stock.new(@id, @name, @stock_count, @purchase_price)
           |> Stock.calculate(new_price)
           |> Stock.detailed_to_string() ==
             "Name: Test \nCount: 100 \nPurchase price: 10.0 \nCost: 1.0e3 \nCurrent price: 8.57 \nWorth: 857.0 \nRate: -14.29 🔴 "
  end
end
