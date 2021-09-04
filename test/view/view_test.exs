defmodule PortfolioTracker.ViewTest do
  use ExUnit.Case
  alias PortfolioTracker.View

  @id "Test"
  @name "Test Market"
  @total 100
  @cost_price 10.0

  test "it_should_return_string_represantation_of_portfolio" do
    portfolio =
      Portfolio.new(@id)
      |> Portfolio.add_stock(Map.put(Stock.new("A", "A_company", 66, 18.20), :rate, 3.0))

    assert View.to_string(portfolio, :short) ==
             "Your Portfolio  \nValue: 1201.22 \nUpdate Time:  \nRate: 0.0 🟢 "
  end

  test "it_should_return_long_string_represantation_of_portfolio" do
    portfolio =
      Portfolio.new(@id)
      |> Portfolio.add_stock(Map.put(Stock.new("A", "A_company", 66, 18.20), :rate, 3.0))

    assert View.to_string(portfolio, :long) ==
             "Your Portfolio \nCost: 1201.22 \nValue: 1201.22 \nUpdate Time:  \nRate: 0.0 🟢   \n------------------------------------- \nName: A \nTotal: 66 \nValue: 1201.21 \nCost price: 18.2 \nPrice: 18.2 \nRate: 3.0 🟢 "
  end

  test "it_should_return_string_represantation_of_stock" do
    new_price = 8.57

    assert Stock.new(@id, @name, @total, @cost_price)
           |> Stock.update(new_price)
           |> View.to_string(:short) == "Name: Test \nValue: 857.0 \nRate: -14.29 🔴 "
  end

  test "it_should_return_long_string_represantation_of_stock" do
    new_price = 8.57

    assert Stock.new(@id, @name, @total, @cost_price)
           |> Stock.update(new_price)
           |> View.to_string(:long) ==
             "Name: Test \nTotal: 100 \nValue: 857.0 \nCost price: 10.0 \nPrice: 8.57 \nRate: -14.29 🔴 "
  end

  test "it_should_return_string_represantation_of_alert_list" do
    alert = Alert.new(:lower_limit, "TUPRS", 12.25)
    alert2 = Alert.new(:upper_limit, "AVISA", 13.25)

    assert View.to_string([alert, alert2]) ==
             "Alerts: \nFor TUPRS lower_limit on 12.25 \nFor AVISA upper_limit on 13.25 \n"
  end
end
