defmodule StockTest do
  use ExUnit.Case

  @id "Test"
  @name "Test Market"
  @total 100
  @cost_price 10.0

  test "it_should_create_stock" do
    assert Stock.new(@id, @name, @total, @cost_price) == %Stock{
             id: @id,
             name: @name,
             total: @total,
             cost_price: @cost_price,
             cost: 1000.0,
             price: 10.0,
             value: 1000.0,
             rate: 0.0
           }
  end

  test "it_should_calculate_stock_value, " do
    new_price = 13.41

    assert Stock.new(@id, @name, @total, @cost_price) |> Stock.update(new_price) ==
             %Stock{
               id: @id,
               name: @name,
               total: @total,
               cost_price: @cost_price,
               cost: 1000.0,
               price: new_price,
               value: 1341.0,
               rate: 34.11
             }
  end

  test "it_should_calculate_stock_value_when_rate_is_negative " do
    new_price = 8.57

    assert Stock.new(@id, @name, @total, @cost_price) |> Stock.update(new_price) ==
             %Stock{
               id: @id,
               name: @name,
               total: @total,
               cost_price: @cost_price,
               cost: 1000.0,
               price: new_price,
               value: 857.0,
               rate: -14.29
             }
  end

  test "it_should_return_string_represantation_of_stock" do
    new_price = 8.57

    assert Stock.new(@id, @name, @total, @cost_price)
           |> Stock.update(new_price)
           |> Stock.to_string() == "Name: Test \nValue: 857.0 \nRate: -14.29 🔴 "
  end

  test "it_should_return_detailed_string_represantation_of_stock" do
    new_price = 8.57

    assert Stock.new(@id, @name, @total, @cost_price)
           |> Stock.update(new_price)
           |> Stock.detailed_to_string() ==
             "Name: Test \nCount: 100 \nPurchase price: 10.0 \nCost: 1.0e3 \nCurrent price: 8.57 \nValue: 857.0 \nRate: -14.29 🔴 "
  end
end
