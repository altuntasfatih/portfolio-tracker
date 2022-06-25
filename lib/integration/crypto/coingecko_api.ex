defmodule PortfolioTracker.Crypto.CoinGeckoApi do
  @behaviour PortfolioTracker.Crypto.Api
  alias PortfolioTracker.Crypto.Api.Models.CryptoPrice
  alias PortfolioTracker.Crypto.CoinGeckoCache

  @currency "usd"

  @impl PortfolioTracker.Crypto.Api
  @spec get_price(maybe_improper_list) ::
          {:error, HTTPoison.Error.t()} | {:ok, %{String.t() => CryptoPrice.t()}}
  def get_price(coin_list) when is_list(coin_list) do
    coins = Enum.join(coin_list, ",")
    url = base_url() <> "/simple/price?ids=#{coins}&vs_currencies=#{@currency}"

    HTTPoison.get(url, headers())
    |> parse()
  end

  @impl PortfolioTracker.Crypto.Api
  def look_up(name), do: CoinGeckoCache.look_up(name)

  def get_coin_list() do
    url = base_url() <> "/coins/list"
    {:ok, response} = HTTPoison.get(url, headers())

    Jason.decode!(response.body)
    |> Enum.reduce(%{}, fn coin, acc ->
      name =
        Map.get(coin, "name")
        |> String.downcase()
        |> String.to_atom()

      Map.put(acc, name, coin)
    end)
  end

  defp parse({:ok, response}) do
    {:ok,
     Jason.decode!(response.body)
     |> Enum.reduce(%{}, fn {name, value}, acc ->
       Map.put(acc, name, %CryptoPrice{name: name, price: value[@currency], currency: @currency})
     end)}
  end

  defp parse(err), do: err

  defp headers() do
    [accept: "Application/json; Charset=utf-8", ContentType: "application/json"]
  end

  defp base_url(), do: Application.get_env(:portfolio_tracker, :crypto)[:coin_gecko_api_url]
end
