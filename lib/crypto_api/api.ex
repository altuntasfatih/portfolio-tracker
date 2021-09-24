defmodule PortfolioTracker.Crypto.Api do
  alias PortfolioTracker.Crypto.Api.Models.CryptoPrice

  @callback get_live_prices(list()) ::
              {:error, any()} | {:ok, %{String.t() => CryptoPrice.t()}} | any
end
