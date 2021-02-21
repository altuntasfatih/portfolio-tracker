defmodule StockListener.StockApi do
  @callback stock_prices() :: {:ok, list} | any

  def stock_prices() do
    Application.get_env(:stock_listener, :stock_api).stock_prices()
  end
end
