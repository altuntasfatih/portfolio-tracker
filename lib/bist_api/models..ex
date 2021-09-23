defmodule PortfolioTracker.Bist.Api.Models do
  defmodule Response do
    defstruct success: false, result: []

    @type t :: %Response{
            success: boolean(),
            result: [StockInfo.t()]
          }

    @spec parse(binary) :: [StockInfo.t()] | []
    def parse(body) when is_binary(body) do
      struct(%Response{}, Jason.decode!(body, keys: :atoms))
      |> get_stocks()
    end

    @spec get_stocks(Response.t()) :: [StockInfo.t()] | []
    defp get_stocks(%Response{success: true, result: prices}), do: prices
    defp get_stocks(%Response{success: false}), do: []
  end

  defmodule StockInfo do
    defstruct name: "", price: 0.0

    @type t :: %StockInfo{
            name: String.t(),
            price: float
          }
  end
end
