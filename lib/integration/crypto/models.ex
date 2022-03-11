defmodule PortfolioTracker.Crypto.Api.Models do
  defmodule CryptoPrice do
    defstruct name: "", price: 0.0, currency: "usd"

    @type t :: %CryptoPrice{
            name: String.t(),
            price: float,
            currency: String.t()
          }
  end
end
