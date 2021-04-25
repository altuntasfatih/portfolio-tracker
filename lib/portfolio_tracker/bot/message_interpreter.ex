defmodule Bot.MessageInterpreter do
  require Logger
  alias PortfolioTracker.CustomSupervisor
  alias PortfolioTracker.Server

  @type instructions ::
          :create
          | :get
          | :get_detail
          | :live
          | :destroy
          | :add_stock
          | :set_alert
          | :delete_stock
          | :help

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
  def process_message(:create, _args, from) do
    case CustomSupervisor.start_listener(from.id) do
      {:ok, _pid} -> {:ok, :portfolio_created}
      {:error, {:already_started, _pid}} -> {:error, :portfolio_already_created}
    end
  end

  def process_message(:get, _args, from),
    do: encode_portfolio(Server.get(from.id), fn p -> Portfolio.to_string(p) end)

  def process_message(:get_detail, _args, from),
    do: encode_portfolio(Server.get(from.id), fn p -> Portfolio.detailed_to_string(p) end)

  def process_message(:live, _args, from),
    do: encode_portfolio(Server.live(from.id), fn p -> Portfolio.detailed_to_string(p) end)

  def process_message(:destroy, _args, from), do: Server.destroy(from.id)

  def process_message(:add_stock, [id, name, count, price], from) do
    with {count, _} <- Integer.parse(count),
         {price, _} <- Float.parse(price) do
      Stock.new(id, name, count, price)
      |> Server.add_stock(from.id)
    else
      _ -> {:error, :args_parse_error}
    end
  end

  def process_message(:add_stock, args, _from) when length(args) != 4,
    do: {:error, :missing_parameter}

  def process_message(:set_alert, [stock_id, target_price], from) do
    with {target_price, _} <- Float.parse(target_price) do
      Server.set_alert(stock_id, target_price, from.id)
    else
      _ -> {:error, :args_parse_error}
    end
  end

  def process_message(:set_alert, _, _), do: {:error, :missing_parameter}

  def process_message(:delete_stock, [stock_id], from),
    do: Server.delete_stock(from.id, stock_id)

  def process_message(:delete_stock, _, _), do: {:error, :missing_parameter}

  def process_message(:help, _args, _from) do
    {:ok, content} = File.read(@help_file)
    {:ok, {content, [parse_mode: :markdown]}}
  end

  def process_message(_, _, _), do: {:error, :instruction_not_found}

  defp prepare_reply({:error, :listener_not_found}),
    do: "There is no portfolio tracker for you, You should create firstly"

  defp prepare_reply({:error, :portfolio_already_created}),
    do: "Your portfolio tracker have already created"

  defp prepare_reply({:ok, :portfolio_created}), do: "Portfolio tracker was created for you"

  defp prepare_reply({:error, :missing_parameter}),
    do: "Argumet/Arguments are missing"

  defp prepare_reply({:error, :args_parse_error}),
    do: "Argumet/Arguments formats are invalid"

  defp prepare_reply({:error, :instruction_not_found}),
    do: "Instruction does not exist"

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

  defp encode_portfolio({:error, err}, _), do: {:error, err}
  defp encode_portfolio(%Portfolio{} = p, encoder), do: {:ok, encoder.(p)}
end
