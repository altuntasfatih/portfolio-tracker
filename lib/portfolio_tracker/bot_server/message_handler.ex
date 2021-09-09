defmodule PortfolioTracker.MessageHandler do
  alias PortfolioTracker.{Supervisor, Tracker, MessageSender, View}

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

  def handle_message(%{from: from} = message) do
    parse(message.text)
    |> handle(from)
    |> View.to_string()
    |> send_reply(from.id)
  end

  def parse("/" <> text) do
    String.trim(text)
    |> String.split(" ")
    |> Enum.filter(fn x -> x != "" end)
    |> parse
  end

  def parse([instruction | args]), do: {String.to_atom(instruction), args}
  def parse(_), do: []

  def handle({instruction, args}, from), do: handle(instruction, args, from)
  def handle([], _), do: {:error, :instruction_not_found}

  def handle(:create, _, from) do
    case Supervisor.start(from.id) do
      {:ok, _pid} -> {:ok, :portfolio_created}
      {:error, {:already_started, _pid}} -> {:error, :portfolio_already_created}
    end
  end

  def handle(:get, _, from) do
    case Tracker.get(from.id) do
      {:error, err} -> {:error, err}
      resp -> View.to_string(resp, :short)
    end
  end

  def handle(:get_detail, _, from) do
    case Tracker.get(from.id) do
      {:error, err} -> {:error, err}
      resp -> View.to_string(resp, :long)
    end
  end

  def handle(:live, _, from), do: Tracker.live(from.id)

  def handle(:destroy, _, from), do: Tracker.destroy(from.id)

  def handle(:add_stock, [name, count, price], from) do
    with {count, _} <- Integer.parse(count),
         {price, _} <- Float.parse(price) do
      Stock.new(name, count, price)
      |> Tracker.add_stock(from.id)
    else
      _ -> {:error, :args_parse_error}
    end
  end

  def handle(:add_stock, _, _), do: {:error, :missing_parameter}

  def handle(:set_alert, [type, stock_name, target_price], from) do
    with {target_price, _} <- Float.parse(target_price),
         type <- String.to_atom(type) do
      Alert.new(type, stock_name, target_price)
      |> Tracker.set_alert(from.id)
    else
      _ -> {:error, :args_parse_error}
    end
  end

  def handle(:set_alert, _, _), do: {:error, :missing_parameter}

  def handle(:remove_alert, [stock_name], from), do: Tracker.remove_alert(from.id, stock_name)

  def handle(:remove_alert, _, _), do: {:error, :missing_parameter}

  def handle(:get_alerts, _, from), do: Tracker.get_alerts(from.id)

  def handle(:delete_stock, [stock_name], from),
    do: Tracker.delete_stock(from.id, stock_name)

  def handle(:delete_stock, _, _), do: {:error, :missing_parameter}

  def handle(:help, _, _) do
    {:ok, content} = File.read(Application.get_env(:portfolio_tracker, :help_file))
    {:ok, {content, [parse_mode: :markdown]}}
  end

  def handle(:start, args, from), do: handle(:help, args, from)

  def handle(_, _, _), do: {:error, :instruction_not_found}

  defp send_reply(message, to), do: MessageSender.send_message(message, to)
end
