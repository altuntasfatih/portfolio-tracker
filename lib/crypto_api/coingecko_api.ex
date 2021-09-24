defmodule PortfolioTracker.Crypto.CoinGeckoApi do
  @behaviour PortfolioTracker.Crypto.Api
  alias PortfolioTracker.Crypto.Api.Models.CryptoPrice

  @currency "usd"
  @url Application.get_env(:portfolio_tracker, :crypto)[:coin_gecko_api_url]

  @impl true
  @spec get_live_prices(maybe_improper_list) ::
          {:error, HTTPoison.Error.t()} | {:ok, %{String.t() => CryptoPrice.t()}}
  def get_live_prices(coin_list) when is_list(coin_list) do
    headers = [
      accept: "Application/json; Charset=utf-8",
      ContentType: "application/json"
    ]

    build_url_for_coin_prices(coin_list)
    |> HTTPoison.get(headers)
    |> parse()
  end

  def build_url_for_coin_prices(coins) do
    coins_query = Enum.join(coins, ",")
    "#{@url}/api/v3/simple/price?ids=#{coins_query}&vs_currencies=#{@currency}"
  end

  defp parse({:ok, response}) do
    {:ok,
     Jason.decode!(response.body)
     |> Enum.reduce(%{}, fn {name, value}, acc ->
       Map.put(acc, name, %CryptoPrice{name: name, price: value[@currency], currency: @currency})
     end)}
  end

  defp parse(err), do: err
end
