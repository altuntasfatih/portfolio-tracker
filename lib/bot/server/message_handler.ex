defmodule PortfolioTracker.Bot.MessageHandler do
  alias PortfolioTracker.{Supervisor, Tracker, Bot.MessageSender, View}

  @type instructions ::
          :create
          | :destroy
          | :get
          | :get_detail
          | :live
          | :get_asset_types
          | :add_asset
          | :delete_asset
          | :set_alert
          | :remove_alert
          | :get_alerts
          | :destroy
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

  @spec handle(instructions(), list(), map()) :: String.t()
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
  def handle(:get_asset_types, _,_from), do: Asset.get_asset_types()

  def handle(:add_asset, [name, type, count, price], from) do
    with {count, _} <- Float.parse(count),
         {price, _} <- Float.parse(price),
         {:ok, type} <- Asset.parse_type(type) do
      Asset.new(name, type, count, price)
      |> Tracker.add_asset(from.id)
    else
      _ -> {:error, :args_parse_error}
    end
  end

  def handle(:add_asset, _, _), do: {:error, :missing_parameter}

  def handle(:set_alert, [type, asset_name, target_price], from) do
    with {target_price, _} <- Float.parse(target_price),
         type <- String.to_atom(type) do
      Alert.new(type, asset_name, target_price)
      |> Tracker.set_alert(from.id)
    else
      _ -> {:error, :args_parse_error}
    end
  end

  def handle(:set_alert, _, _), do: {:error, :missing_parameter}

  def handle(:remove_alert, [asset_name], from), do: Tracker.remove_alert(from.id, asset_name)

  def handle(:remove_alert, _, _), do: {:error, :missing_parameter}

  def handle(:get_alerts, _, from), do: Tracker.get_alerts(from.id)

  def handle(:delete_asset, [asset_name], from),
    do: Tracker.delete_asset(from.id, asset_name)

  def handle(:delete_asset, _, _), do: {:error, :missing_parameter}

  def handle(:help, _, _), do: :help

  def handle(:start, args, from), do: handle(:help, args, from)

  def handle(_, _, _), do: {:error, :instruction_not_found}

  defp send_reply(message, to), do: MessageSender.send_message(message, to)
end
