defmodule StockListener do
  @moduledoc """
  Documentation for `StockListener`.
  """
  use GenServer
  require Logger

  def start_link(%StockPortfolio{} = state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def start_link(id) do
    start_link(StockPortfolio.new(id))
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    Logger.info("Get -> #{state}")
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:add_stock, %Stock{} = stock}, state) do
    {:noreply, StockPortfolio.add_stock(state, stock)}
  end

  @impl true
  def handle_cast({:update_stocks, new_stocks}, state) do
    {:noreply, StockPortfolio.update_stocks(state, new_stocks)}
  end

  @impl true
  def handle_cast(:update_prices, state), do: handle_info(:update_prices, state)

  @impl true
  def handle_info(:update_prices, %StockPortfolio{stocks: []} = state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(:update_prices, %StockPortfolio{stocks: stocks} = state) do
    Logger.info("Update prices -> #{state}")
    {:noreply, StockPortfolio.update_stocks(state, update_stock_prices(stocks))}
  end

  @impl true
  def handle_info(:timeout, _) do
    {:stop, :normal, []}
  end

  def update_stock_prices(stocks, current_prices) do
    Enum.map(stocks, fn s ->
      Enum.find(current_prices, fn x -> s.id == x.name end)
      |> update_price(s)
    end)
  end

  defp update_stock_prices(stocks) do
    {:ok, current_prices} = StockClient.stock_prices()
    update_stock_prices(stocks, current_prices)
  end

  defp update_price(nil, stock), do: stock
  defp update_price(c, stock), do: Stock.calculate(stock, c.price)

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def add_stock(%Stock{} = stock) do
    GenServer.cast(__MODULE__, {:add_stock, stock})
  end

  def update_prices() do
    GenServer.cast(__MODULE__, :update_prices)
  end

  def update_stocks(stocks) when is_list(stocks) do
    GenServer.cast(__MODULE__, {:update_stocks, stocks})
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :transient,
      shutdown: 500
    }
  end
end
