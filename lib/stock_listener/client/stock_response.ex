defmodule StockPricesResponse do
  @derive [Poison.Decoder]
  defstruct success: false, result: []

  def parse(body) when is_binary(body) do
    Poison.decode!(body, as: %StockPricesResponse{})
    |> get_stocks()
    |> Enum.map(fn x -> for {key, val} <- x, into: %{}, do: {String.to_atom(key), val} end)
  end

  defp get_stocks(%StockPricesResponse{success: true, result: prices}), do: prices
  defp get_stocks(%StockPricesResponse{success: false}), do: []
end
