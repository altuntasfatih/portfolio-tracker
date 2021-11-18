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
      |> Portfolio.add_asset(Map.put(Asset.new("A", @asset_type, 66, 18.20), :rate, 3.0))

    assert View.to_str(portfolio, :short) ==
             "Your portfolio:\n\nValue: 1201.22\nRate: 0.0 🟢 \nTime: "
  end

  test "it_should_return_long_string_represantation_of_portfolio" do
    portfolio =
      Portfolio.new(@id)
      |> Portfolio.add_asset(Map.put(Asset.new("A", @asset_type, 66, 18.20), :rate, 3.0))

    assert View.to_str(portfolio, :long) ==
             "Your portfolio:\n\nValue: 1201.22\nCost: 1201.22\nRate: 0.0 🟢 \nTime: \n \nName: A\nValue: 1201.21\nTotal: 66\nPrice: 18.2\nCost Price:  18.2\nRate: 3.0 🟢 \n"
  end

  test "it_should_return_string_represantation_of_asset" do
    new_price = 8.57

    assert Asset.new(@name, @asset_type, @total, @cost_price)
           |> Asset.update(new_price)
           |> View.to_str(:short) == "Name: Test_asset\nValue: 857.0\nRate: -14.29 🔴 "
  end

  test "it_should_return_long_string_represantation_of_asset" do
    new_price = 8.57

    assert Asset.new(@name, @asset_type, @total, @cost_price)
           |> Asset.update(new_price)
           |> View.to_str(:long) ==
             "Name: " <>
               @name <>
               "\nValue: 857.0\nTotal: 100\nPrice: 8.57\nCost Price:  10.0\nRate: -14.29 🔴 "
  end

  test "it_should_return_string_represantation_of_alert_list" do
    alert = Alert.new(:lower_limit, "TUPRS",:bist, 12.25)
    alert2 = Alert.new(:upper_limit, "AVISA",:bist, 13.25)

    assert View.to_str([alert, alert2]) ==
             "Your Alerts:\nAlert For: TUPRS\nType: lower_limit\nTarget: 12.25\n\nAlert For: AVISA\nType: upper_limit\nTarget: 13.25\n\n"
  end

  test "it_should_string_represantation_of_asset_types" do
    assert Asset.get_asset_types() |> View.to_str() ==
             ":bist    The Borsa Istanbul Stock\n:crypto  Crypto Currency"
  end
end
