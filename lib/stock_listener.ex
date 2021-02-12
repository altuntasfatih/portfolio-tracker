defmodule StockListener do
  @moduledoc """
  Documentation for `StockListener`.
  """
  use GenServer
  require Logger

  def start_link(%StockPortfolio{} = state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(state) do
    ## :timer.send_interval(1000, :update)
    {:ok, state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    Logger.info("Get -> #{state}")
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:update_stocks, stocks}, state) do
    {:noreply, StockPortfolio.update_stocks(state, stocks)}
  end

  @impl true
  def handle_cast({:add, %Stock{} = stock}, state) do
    {:noreply, StockPortfolio.add_stock(state, stock)}
  end

  @impl true
  def handle_info(:update_portfolio, %StockPortfolio{stocks: []} = state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(:update_portfolio, %StockPortfolio{stocks: stocks} = state) do
    Logger.info("Update portfolio -> #{state}")
    {:noreply, StockPortfolio.update_stocks(state, update_stock_value(stocks))}
  end

  @impl true
  def handle_info(:timeout, _) do
    {:stop, :normal, []}
  end

  def update_stock_value(stocks, stocks_info) do
    Enum.map(stocks, fn s ->
      update_stock(s, Enum.find(stocks_info, fn x -> s.id == x.name end))
    end)
  end

  defp update_stock_value(stocks) do
    {:ok, stocks_info} = StockClient.stock_prices()

    Enum.map(stocks, fn s ->
      update_stock(s, Enum.find(stocks_info, fn x -> s.id == x.name end))
    end)
  end

  defp update_stock(stock, nil), do: stock

  defp update_stock(stock, stock_info) do
    Stock.calculate(stock, stock_info.price)
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def add_stock(%Stock{} = stock) do
    GenServer.cast(__MODULE__, {:add, stock})
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
