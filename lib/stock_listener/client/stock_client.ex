defmodule StockClient do
  @token "apikey 1hMoXHboCriCLsuorHwr0t:54DcwpMehYTRBUvfDQRfFz"
  @url "https://api.collectapi.com/economy/liveBorsa"

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
