defmodule PortfolioTracker.Crypto.CoinGeckoCache do
  use GenServer
  alias PortfolioTracker.Crypto.CoinGeckoApi

  @table :coin_id_cache

  def start_link(_) do
    GenServer.start_link(__MODULE__, @table, name: __MODULE__)
  end

  def init(table_name) do
    ^table_name = :ets.new(table_name, [:named_table])

    for {coin_name, coin} <- CoinGeckoApi.get_coin_list() do
      :ets.insert(table_name, {coin_name, coin["id"]})
    end

    {:ok, table_name}
  end

  def look_up(name) do
    name = String.downcase(name) |> String.to_atom()

    case :ets.lookup(@table, name) do
      [{_, id}] -> {:ok, id}
      [] -> {:error, :coin_not_found}
    end
  end
end
