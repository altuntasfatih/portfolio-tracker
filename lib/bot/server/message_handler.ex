defmodule PortfolioTracker.Bot.MessageHandler do
  alias PortfolioTracker.{Supervisor, Tracker, Bot.MessageSender, View}

  @type command ::
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
    parse_command(message.text)
    |> handle(from.id)
    |> send_reply(from.id)
  end

  def parse_command("/" <> text) do
    String.trim(text)
    |> String.split(" ")
    |> Enum.filter(fn x -> x != "" end)
    |> parse_command()
  end

  def parse_command([command | args]), do: {String.to_atom(command), args}
  def parse_command(_), do: []

  def handle({instruction, args}, from), do: handle(instruction, args, from)
  def handle([], _), do: {:error, :instruction_not_found}

  @spec handle(command(), arguments :: list(), map()) :: String.t()
  def handle(:create, _, from) do
    case Supervisor.start(from) do
      {:ok, _pid} -> {:ok, :portfolio_created}
      {:error, {:already_started, _pid}} -> {:error, :portfolio_already_created}
    end
  end

  # todo tracher should return {:ok,result} or {:error, err}
  # use with to remove redundant code
  def handle(:get, _, from) do
    case Tracker.get(from) do
      {:error, err} -> {:error, err}
      {:ok, resp} -> View.to_str(resp, :short)
    end
  end

  def handle(:get_detail, _, from) do
    case Tracker.get(from) do
      {:error, err} -> {:error, err}
      {:ok, resp} -> View.to_str(resp, :long)
    end
  end

  def handle(:live, _, from), do: Tracker.live(from)
  def handle(:destroy, _, from), do: Tracker.destroy(from)
  def handle(:get_asset_types, _, _from), do: Asset.get_asset_types()

  def handle(:add_asset, [name, type, count, price], from) do
    with {count, _} <- Float.parse(count),
         {price, _} <- Float.parse(price),
         {:ok, type} <- Asset.parse_type(type) do
      Asset.new(name, type, count, price)
      |> Tracker.add_asset(from)
    else
      _ -> {:error, :args_parse_error}
    end
  end

  def handle(:add_asset, _, _), do: {:error, :missing_parameter}

  def handle(:set_alert, [type, asset_name, asset_type, target_price], from) do
    with {target_price, _} <- Float.parse(target_price),
         alert_type <- String.to_atom(type),
         asset_type <- String.to_atom(asset_type) do
      Alert.new(alert_type, asset_name, asset_type, target_price)
      |> Tracker.set_alert(from)
    else
      _ -> {:error, :args_parse_error}
    end
  end

  def handle(:set_alert, _, _), do: {:error, :missing_parameter}

  def handle(:remove_alert, [asset_name], from), do: Tracker.remove_alert(from, asset_name)

  def handle(:remove_alert, _, _), do: {:error, :missing_parameter}

  def handle(:get_alerts, _, from), do: Tracker.get_alerts(from)

  def handle(:delete_asset, [asset_name], from),
    do: Tracker.delete_asset(from, asset_name)

  def handle(:delete_asset, _, _), do: {:error, :missing_parameter}

  def handle(:help, _, _), do: :help

  def handle(:start, args, from), do: handle(:help, args, from)

  def handle(_, _, _), do: {:error, :instruction_not_found}

  defp send_reply(message, to), do: MessageSender.send_message(message, to)
end
