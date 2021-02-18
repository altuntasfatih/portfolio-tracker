defmodule StockListener.Message do
  require Logger

  @pattern " "
  def process_message(message) do
    [instruction | args] =
      String.trim(message.text) |> String.split(@pattern) |> Enum.filter(fn x -> x != "" end)

    print(instruction, args)
    process_message(instruction, args, message)
  end

  def process_message("start", args, message) do
    {:ok, id} = StockListener.start_link(message.from.id)
    "listener was stared"
  end

  def process_message("get", args, _), do: StockListener.get()

  def process_messag("current", args, _) do
    StockListener.get()
  end

  def process_message("add", [id, name, count, price, target_price], _) do
    with {count, _} <- Integer.parse(count),
         {price, _} = Float.parse(price),
         {target_price, _} = Float.parse(target_price) do
      Stock.new(id, name, count, price, target_price)
      |> StockListener.add_stock()
    else
      :error -> "Parse error"
    end
  end

  def process_message("add", _, _), do: "Arg is missing"

  def process_message(_, args, _), do: ""

  defp print(message, []) do
    ("Incoming message -> " <> message)
    |> Logger.info()
  end

  defp print(message, args) do
    ("Incoming message -> " <> message <> ", " <> "args -> " <> Enum.join(args, ", "))
    |> Logger.info()
  end
end
