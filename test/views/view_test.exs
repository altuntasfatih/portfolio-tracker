defmodule PortfolioTracker.ViewTest do
  use ExUnit.Case
  alias PortfolioTracker.View

  @id "Test"
  @name "Test_asset"
  @asset_type :crypto
  @total 100
  @cost_price 10.0

  test "it_should_return_string_represantation_of_portfolio" do
    portfolio =
      Portfolio.new(@id)
      |> Portfolio.add_asset(Map.put(Asset.new("A", 66, 18.20), :rate, 3.0))

    assert View.to_str(portfolio, :short) ==
             "Your portfolio:\n\nTotal value: 1201.22 USD\nRate: +% 0.0 🟢"
  end

  test "it_should_return_long_string_represantation_of_portfolio" do
    portfolio =
      Portfolio.new(@id)
      |> Portfolio.add_asset(Map.put(Asset.new("A", 66, 18.20), :rate, 3.0))

    assert View.to_str(portfolio, :long) ==
             "Your portfolio:\n\nTotal value: 1201.22 USD\nTotal cost: 1201.22 USD\nRate: +% 0.0 🟢\n \nAsset: A\nTotal: 66 \nPrice: 18.2 USD\nCost : 18.2 USD\nValue: 1201.21 USD\nRate: +% 3.0 🟢\n\n"
  end

  test "it_should_return_string_represantation_of_asset" do
    new_price = 8.57

    assert Asset.new(@name, @total, @cost_price)
           |> Asset.update(new_price)
           |> View.to_str(:short) == "Asset: Test_asset\nValue: 857.0 USD\nRate: -% -14.29 🔴"
  end

  test "it_should_return_long_string_represantation_of_asset" do
    new_price = 8.57

    assert Asset.new(@name, @total, @cost_price)
           |> Asset.update(new_price)
           |> View.to_str(:long) ==
             "Asset: Test_asset\nTotal: 100 \nPrice: 8.57 USD\nCost : 10.0 USD\nValue: 857.0 USD\nRate: -% -14.29 🔴"
  end

  test "it_should_return_string_represantation_of_alert_list" do
    alert = Alert.new(:lower_limit, "Avax", 12.25)
    alert2 = Alert.new(:upper_limit, "Eth", 13.25)

    assert View.to_str([alert, alert2]) ==
             "Your Alerts:\nAlert For: Avax\nType: lower_limit\nTarget: 12.25 USD\n\nAlert For: Eth\nType: upper_limit\nTarget: 13.25 USD\n\n"
  end
end
