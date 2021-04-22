defmodule PortfolioTracker.CollectApi do
  @behaviour PortfolioTracker.ExchangeApi
  alias PortfolioTracker.ExchangeApi.StockPricesResponse

  @token Application.fetch_env!(:portfolio_tracker, :token)
  @url Application.fetch_env!(:portfolio_tracker, :url)

  def get_live_prices() do
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

  def get_attributes() do
    {@token, @url}
  end
end