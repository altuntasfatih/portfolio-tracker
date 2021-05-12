defmodule Bot.MessageConsumer do
  require Logger
  alias PortfolioTracker.ServerSupervisor
  alias PortfolioTracker.Server
  alias Bot.Manager

  @type instructions ::
          :create
          | :get
          | :get_detail
          | :live
          | :destroy
          | :add_stock
          | :set_alert
          | :remove_alert
          | :get_alerts
          | :delete_stock
          | :start
          | :help

  @help_file "./resource/help.md"
  @pattern " "

  @spec consume_message(atom | %{:text => binary, optional(any) => any}) :: any
  def consume_message(message) do
    case parse_message(message.text) do
      [instruction | args] ->
        log(instruction, args)

        String.to_atom(instruction)
        |> message_handler(args, message.from)
        |> prepare_reply

      _ ->
        prepare_reply({:error, :instruction_not_found})
    end
  end

  defp parse_message("/" <> text) do
    String.trim(text)
    |> String.split(@pattern)
    |> Enum.filter(fn x -> x != "" end)
  end

  defp parse_message(_), do: []

  def message_handler(:create, _, from) do
    case ServerSupervisor.start_server(from.id) do
      {:ok, _pid} -> {:ok, :portfolio_created}
      {:error, {:already_started, _pid}} -> {:error, :portfolio_already_created}
    end
  end

  def message_handler(:get, _, from),
    do: convert_data(Server.get(from.id), fn p -> Portfolio.to_string(p) end)

  def message_handler(:get_detail, _, from),
    do: convert_data(Server.get(from.id), fn p -> Portfolio.detailed_to_string(p) end)

  def message_handler(:live, _, from),
    do: convert_data(Server.live(from.id), fn p -> Portfolio.detailed_to_string(p) end)

  def message_handler(:destroy, _, from), do: Server.destroy(from.id)

  def message_handler(:add_stock, [id, name, count, price], from) do
    with {count, _} <- Integer.parse(count),
         {price, _} <- Float.parse(price) do
      Stock.new(id, name, count, price)
      |> Server.add_stock(from.id)
    else
      _ -> {:error, :args_parse_error}
    end
  end

  def message_handler(:add_stock, _, _), do: {:error, :missing_parameter}

  def message_handler(:set_alert, [type, stock_id, target_price], from) do
    with {target_price, _} <- Float.parse(target_price),
         type <- String.to_atom(type) do
      Alert.new(type, stock_id, target_price)
      |> Server.set_alert(from.id)
    else
      _ -> {:error, :args_parse_error}
    end
  end

  def message_handler(:set_alert, _, _), do: {:error, :missing_parameter}

  def message_handler(:remove_alert, [stock_id], from), do: Server.remove_alert(from.id, stock_id)

  def message_handler(:remove_alert, _, _), do: {:error, :missing_parameter}

  def message_handler(:get_alerts, _, from),
    do: convert_data(Server.get_alerts(from.id), &Enum.join(&1))

  def message_handler(:delete_stock, [stock_id], from),
    do: Server.delete_stock(from.id, stock_id)

  def message_handler(:delete_stock, _, _), do: {:error, :missing_parameter}

  def message_handler(:help, _, _) do
    {:ok, content} = File.read(@help_file)
    {:ok, {content, [parse_mode: :markdown]}}
  end

  def message_handler(:start, args, from), do: message_handler(:help, args, from)

  def message_handler(_, _, _), do: {:error, :instruction_not_found}

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

  defp log(message, []) do
    ("Incoming message -> " <> message)
    |> Logger.info()
  end

  defp log(message, args) do
    ("Incoming message -> " <> message <> ", " <> "args -> " <> Enum.join(args, ", "))
    |> Logger.info()
  end

  defp convert_data({:error, err}, _), do: {:error, err}
  defp convert_data({:ok, data}, func), do: {:ok, func.(data)}
  defp convert_data(data, func), do: {:ok, func.(data)}

  def send_reply(message, to) do
    Manager.send_message_user(message, to)
  end
end
