defmodule PortfolioTracker.CollectionApi do
  @behaviour PortfolioTracker.StockApi
  alias PortfolioTracker.StockApi.StockPricesResponse

  def get_live_prices() do
    headers = [
      authorization: Application.get_env(:collection_api, :token),
      accept: "Application/json; Charset=utf-8",
      ContentType: "application/json"
    ]

    case HTTPoison.post(Application.get_env(:collection_api, :url), "", headers) do
      {:ok, response} ->
        {:ok, StockPricesResponse.parse(response.body)}

      err ->
        err
    end
  end
end
