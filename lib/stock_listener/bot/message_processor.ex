defmodule Bot.MessageProcessor do
  require Logger

  @type instructions :: :get | :start | :current | :add | :help
  @help_reply "
/start    -> it start new stock lister for you. \n
/get      -> it gets your stock portfolio. \n
/add      -> it adds stock to your portfolio,
          e.g. /add id name count price target_price
          (id must be same with exchanges id/name) \n
/current  -> it calculates your portfolio with live prices. \n
/help     -> help()."

  @pattern " "

  def process_message(message) do
    [instruction | args] =
      String.trim(message.text)
      |> String.split(@pattern)
      |> Enum.filter(fn x -> x != "" end)

    print(instruction, args)

    String.slice(instruction, 1..-1)
    |> String.to_atom()
    |> process_message(args, message.from)
    |> prepare_reply
  end

  @spec process_message(instructions, list, any) :: any
  def process_message(:start, _args, from) do
    case StockListener.start_link(from.id) do
      {:ok, _pid} -> {:ok, :listener_started}
      {:error, {:already_started, _pid}} -> {:error, :listener_already_started}
    end
  end

  def process_message(:get, _args, from), do: StockListener.get(from.id)

  def process_message(:current, _args, from), do: StockListener.current(from.id)

  def process_message(:add, [id, name, count, price, target_price], from) do
    with {count, _} <- Integer.parse(count),
         {price, _} <- Float.parse(price),
         {target_price, _} <- Float.parse(target_price) do
      Stock.new(id, name, count, price, target_price)
      |> StockListener.add_stock(from.id)
    else
      _ -> {:error, :args_parse_error}
    end
  end

  def process_message(:add, args, _from) when length(args) != 5, do: {:error, :missing_parameter}

  def process_message(:help, _args, _from), do: {:ok, @help_reply}

  def process_message(_, _, _), do: {:error, :instruction_not_found}

  defp prepare_reply({:error, :listener_not_found}),
    do: "There is no stock listener for you, You should create first"

  defp prepare_reply({:error, :listener_already_started}),
    do: "Your stock listener have already been created"

  defp prepare_reply({:error, :missing_parameter}),
    do: "Argumet/Arguments are missing"

  defp prepare_reply({:error, :args_parse_error}),
    do: "Argumet/Arguments formats are invalid"

  defp prepare_reply({:error, :instruction_not_found}),
    do: "Instruction does not exist"

  defp prepare_reply({:ok, :listener_started}), do: "Stock listener was created for you"
  defp prepare_reply({:ok, reply}), do: reply
  defp prepare_reply(r), do: r

  defp print(message, []) do
    ("Incoming message -> " <> message)
    |> Logger.info()
  end

  defp print(message, args) do
    ("Incoming message -> " <> message <> ", " <> "args -> " <> Enum.join(args, ", "))
    |> Logger.info()
  end
end
