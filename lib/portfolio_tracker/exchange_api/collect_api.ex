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

  def get_live_prices(name_list) when is_list(name_list) do
    {:ok, current_prices} = get_live_prices()
    {:ok, Enum.filter(current_prices, fn s -> s.name in name_list end)}
  end

  def get_attributes() do
    {@token, @url}
  end
end
