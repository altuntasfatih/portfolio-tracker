defmodule PortfolioTracker.Crypto.CoinGeckoCache do
  use GenServer

  @table :coin_id_cache

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    table_name =  @table
    ^table_name = :ets.new(table_name, [:named_table])
  end

end
