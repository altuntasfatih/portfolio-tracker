defmodule Bot.MessageProcessor do
  require Logger
  alias StockListener.MySupervisor
  alias StockListener.Server

  @type instructions :: :get | :start | :live | :add | :delete | :help

  @help_file "./resource/help.md"

  @pattern " "
  def process_message(message) do
    case preprocess_text(message.text) do
      [instruction | args] ->
        print(instruction, args)

        String.slice(instruction, 1..-1)
        |> String.to_atom()
        |> process_message(args, message.from)
        |> prepare_reply

      _ ->
        prepare_reply({:error, :instruction_not_found})
    end
  end

  @spec preprocess_text(binary) :: list
  defp preprocess_text(nil), do: []

  defp preprocess_text(text) do
    String.trim(text)
    |> String.split(@pattern)
    |> Enum.filter(fn x -> x != "" end)
  end

  @spec process_message(instructions, list, any) :: any
  def process_message(:start, _args, from) do
    case MySupervisor.start_listener(from.id) do
      {:ok, _pid} -> {:ok, :listener_started}
      {:error, {:already_started, _pid}} -> {:error, :listener_already_started}
    end
  end

  def process_message(:get, _args, from), do: Server.get(from.id)

  def process_message(:live, _args, from), do: Server.get_live(from.id)

  def process_message(:add, [id, name, count, price, target_price], from) do
    with {count, _} <- Integer.parse(count),
         {price, _} <- Float.parse(price),
         {target_price, _} <- Float.parse(target_price) do
      Stock.new(id, name, count, price, target_price)
      |> Server.add_stock(from.id)
    else
      _ -> {:error, :args_parse_error}
    end
  end

  def process_message(:add, args, _from) when length(args) != 5, do: {:error, :missing_parameter}

  def process_message(:delete, [stock_id], from),
    do: Server.delete_stock(from.id, stock_id)

  def process_message(:delete, _, _), do: {:error, :missing_parameter}

  def process_message(:help, _args, _from) do
    {:ok, content} = File.read(@help_file)
    {:ok, {content, [parse_mode: :markdown]}}
  end

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
