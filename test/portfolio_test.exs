defmodule PortfolioTest do
  use ExUnit.Case

  @id "Fatih"
  test "it_should_create_portfolio" do
    assert Portfolio.new(@id) == %Portfolio{
             id: @id,
             stocks: %{},
             total_worth: 0,
             total_cost: 0,
             rate: 0
           }
  end

  test "it_should_calculate_portfolio" do
    portfolio = Portfolio.new(@id)
    stock = Stock.new("A", "A_company", 66, 18.20) |> Stock.calculate(19.32)
    stock2 = Stock.new("E", "E_company", 460, 14.47) |> Stock.calculate(14.60)
    stock3 = Stock.new("S", "S_company", 84, 14.28) |> Stock.calculate(14.48)
    stock4 = Stock.new("D", "D_company", 10, 110.22) |> Stock.calculate(100.70)

    portfolio =
      Portfolio.add_stock(portfolio, stock)
      |> Portfolio.add_stock(stock2)
      |> Portfolio.add_stock(stock3)
      |> Portfolio.add_stock(stock4)

    assert portfolio.total_worth == 10214.45
    assert portfolio.total_cost == 10159.15
    assert portfolio.rate == 0.55
  end

  test "it_should_sort_stocks_by_rate" do
    portfolio = Portfolio.new(@id)
    stock = Map.put(Stock.new("A", "A_company", 66, 18.20), :rate, 3.0)
    stock2 = Map.put(Stock.new("E", "E_company", 460, 14.47), :rate, 0.0)
    stock3 = Map.put(Stock.new("S", "S_company", 84, 14.28), :rate, -10.0)
    stock4 = Map.put(Stock.new("D", "D_company", 84, 14.28), :rate, 7.0)

    portfolio =
      Portfolio.add_stock(portfolio, stock)
      |> Portfolio.add_stock(stock2)
      |> Portfolio.add_stock(stock3)
      |> Portfolio.add_stock(stock4)

    assert Portfolio.get_stocks(portfolio) == [stock4, stock, stock2, stock3]
  end

  test "it_should_return_string_represantation_of_portfolio" do
    portfolio =
      Portfolio.new(@id)
      |> Portfolio.add_stock(Map.put(Stock.new("A", "A_company", 66, 18.20), :rate, 3.0))

    assert Portfolio.to_string(portfolio) ==
             "Worth: 1201.21 \nUpdate Time:  \nRate: 0.0 🟢   \n------------------------------------- \nName: A \nWorth: 1201.21 \nRate: 3.0 🟢 "
  end

  test "it_should_return_detailed_string_represantation_of_portfolio" do
    portfolio =
      Portfolio.new(@id)
      |> Portfolio.add_stock(Map.put(Stock.new("A", "A_company", 66, 18.20), :rate, 3.0))

    assert Portfolio.detailed_to_string(portfolio) ==
             "Portfolio Id: Fatih \nCost: 1201.21 \nWorth: 1201.21 \nUpdate Time:  \nRate: 0.0 🟢   \n------------------------------------- \nName: A \nCount: 66 \nPurchase price: 18.2 \nCost: 1201.21 \nCurrent price: 18.2 \nWorth: 1201.21 \nRate: 3.0 🟢  "
  end
end
