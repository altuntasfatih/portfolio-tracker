defmodule PortfolioTracker.Bist.CollectApi do
  @behaviour PortfolioTracker.Bist.Api
  alias PortfolioTracker.Bist.Api.Models.{Response, StockInfo}

  @impl true
  @spec get_price(list()) ::
          {:error, HTTPoison.Error.t()} | {:ok, %{String.t() => StockInfo.t()}}
  def get_price(stock_list) do
    headers = [
      authorization: token(),
      accept: "Application/json; Charset=utf-8",
      ContentType: "application/json"
    ]

    HTTPoison.post(base_url(), "", headers)
    |> parse(stock_list)
  end

  defp parse({:ok, response}, stock_list) do
    stocks =
      Response.parse(response.body)
      |> Enum.filter(fn s -> s.name in stock_list end)
      |> Enum.reduce(%{}, fn stock, acc -> Map.put(acc, stock.name, stock) end)

    {:ok, stocks}
  end

  defp parse(err, _), do: err

  defp base_url(), do: Application.get_env(:portfolio_tracker, :bist)[:collect_api_url]
  defp token(), do: Application.get_env(:portfolio_tracker, :bist)[:collect_api_token]
end
