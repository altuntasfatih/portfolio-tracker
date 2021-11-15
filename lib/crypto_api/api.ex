defmodule PortfolioTracker.Crypto.Api do
  alias PortfolioTracker.Crypto.Api.Models.CryptoPrice

  @callback get_price(list()) ::
              {:error, any()} | {:ok, %{String.t() => CryptoPrice.t()}} | any

  @callback look_up(String.t()) ::
              {:error, any()} | {:ok, String.t()}

  def get_price(list), do: impl().get_price(list)
  def look_up(name), do: impl().look_up(name)
  defp impl, do: Application.get_env(:portfolio_tracker, :crypto)[:api]
end
