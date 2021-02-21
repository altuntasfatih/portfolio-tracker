defmodule StockListener.CollectionApi do
  @behaviour StockListener.StockApi
  alias StockListener.StockApi.StockPricesResponse

  @token "apikey 1hMoXHboCriCLsuorHwr0t:54DcwpMehYTRBUvfDQRfFz"
  @url "https://api.collectapi.com/economy/liveBorsa"

  @spec stock_prices :: {:error, HTTPoison.Error.t()} | {:ok, list}
  def stock_prices() do
    headers = [
      authorization: @token,
      accept: "Application/json; Charset=utf-8",
      ContentType: "application/json"
    ]

    case HTTPoison.post(@url, "", headers) do
      {:ok, response} ->
        {:ok, StockPricesResponse.parse(response.body)}

      err ->
        err
    end
  end
end
