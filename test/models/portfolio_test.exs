defmodule PortfolioTest do
  use ExUnit.Case

  @id "Fatih"
  test "it_should_create_portfolio" do
    assert Portfolio.new(@id) == %Portfolio{
             id: @id,
             assets: %{},
             cost: 0.0,
             value: 0.0,
             rate: 0.0
           }
  end

  test "it_should_calculate_portfolio" do
    asset = Asset.new("A", 66, 18.20) |> Asset.update(19.32)
    asset2 = Asset.new("E", 460, 14.47) |> Asset.update(14.60)
    asset3 = Asset.new("S", 84, 14.28) |> Asset.update(14.48)
    asset4 = Asset.new("D", 10, 110.22) |> Asset.update(100.70)

    portfolio =
      Portfolio.new(@id)
      |> Portfolio.add_asset(asset)
      |> Portfolio.add_asset(asset2)
      |> Portfolio.add_asset(asset3)
      |> Portfolio.add_asset(asset4)

    assert portfolio.value == 102_14.46
    assert portfolio.cost == 101_59.16
    assert portfolio.rate == 0.55
  end

  test "it_should_sort_assets_by_rate" do
    asset = Map.put(Asset.new("A", 66, 18.20), :rate, 3.0)
    asset2 = Map.put(Asset.new("E", 460, 14.47), :rate, 0.0)
    asset3 = Map.put(Asset.new("S", 84, 14.28), :rate, -10.0)
    asset4 = Map.put(Asset.new("D", 84, 14.28), :rate, 7.0)

    portfolio =
      Portfolio.new(@id)
      |> Portfolio.add_asset(asset)
      |> Portfolio.add_asset(asset2)
      |> Portfolio.add_asset(asset3)
      |> Portfolio.add_asset(asset4)

    assert Portfolio.get_assets_by_order(portfolio) == [asset4, asset, asset2, asset3]
  end

  test "it_should_add_alert_for_asset" do
    alert = Alert.new(:upper_limit, "A", 20.0)
    portfolio = Portfolio.new(@id)

    assert Portfolio.add_alert(portfolio, alert).alerts == [alert]
  end

  test "it_should_remove_alert" do
    alert = Alert.new(:upper_limit, "A", 20.0)
    portfolio = Portfolio.new(@id) |> Portfolio.add_alert(alert)

    assert Portfolio.remove_alert(portfolio, alert.asset_id).alerts == []
  end
end
