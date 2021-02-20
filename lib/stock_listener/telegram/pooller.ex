defmodule StockListener.Telegram.Pooler do
  use GenServer
  import StockListener.Telegram.MessageProcessor

  @interval 1000
  def start_link(offset) do
    GenServer.start_link(__MODULE__, offset, name: __MODULE__)
  end

  @impl true
  def init(offset) do
    call_itself()
    {:ok, offset}
  end

  @impl true
  def handle_info(:get_messages, offset) do
    {:ok, update} = Nadia.get_updates(offset: offset, limit: 1)
    call_itself()
    {:noreply, process(update, offset)}
  end

  def process([], offset), do: offset
  def process([u], _), do: process(u)
  def process(%{message: nil, update_id: id}), do: id + 1

  def process(%{message: message, update_id: id}) do
    process_message(message)
    |> send_reply(message.from.id)

    id + 1
  end

  defp send_reply("", _), do: :ok
  defp send_reply(message, from), do: {:ok, _} = Nadia.send_message(from, message)

  defp call_itself(), do: Process.send_after(self(), :get_messages, @interval)
end
