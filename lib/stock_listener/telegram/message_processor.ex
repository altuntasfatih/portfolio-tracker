defmodule StockListener.Telegram.MessageProcessor do
  require Logger

  @pattern " "
  def process_message(nil) do
  end

  def process_message(message) do
    [instruction | args] =
      String.trim(message.text) |> String.split(@pattern) |> Enum.filter(fn x -> x != "" end)

    print(instruction, args)
    process_message(instruction, args, message)
  end

  def process_message("get", _args, m), do: StockListener.get(m.from.id)

  def process_message("start", _args, m) do
    {:ok, _id} = StockListener.start_link(m.from.id)
    "Stock listener was created for you"
  end

  def process_message("current", _args, m), do: StockListener.current(m.from.id)

  def process_message("add", [id, name, count, price, target_price], m) do
    with {count, _} <- Integer.parse(count),
         {price, _} = Float.parse(price),
         {target_price, _} = Float.parse(target_price) do
      Stock.new(id, name, count, price, target_price)
      |> StockListener.add_stock(m.from.id)
    else
      :error -> "Parse error"
    end
  end

  def process_message("add", [], _m), do: "Arg is missing"

  def process_message(i, _, _), do: "There is no instruction for " <> i

  defp print(message, []) do
    ("Incoming message -> " <> message)
    |> Logger.info()
  end

  defp print(message, args) do
    ("Incoming message -> " <> message <> ", " <> "args -> " <> Enum.join(args, ", "))
    |> Logger.info()
  end
end
