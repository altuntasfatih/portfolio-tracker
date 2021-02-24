defmodule StockListener.StockApi.StockPricesResponse do
  alias StockListener.StockApi.StockPricesResponse
  defstruct success: false, result: []

  @spec parse(binary) :: list
  def parse(body) when is_binary(body) do
    struct(%StockPricesResponse{}, Jason.decode!(body, keys: :atoms))
    |> get_stocks()
    |> Enum.map(fn x -> for {key, val} <- x, into: %{}, do: {String.to_atom(key), val} end)
  end

  defp get_stocks(%StockPricesResponse{success: true, result: prices}), do: prices
  defp get_stocks(%StockPricesResponse{success: false}), do: []
end
