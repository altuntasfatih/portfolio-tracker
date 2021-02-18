defmodule StockListener.Telegram.Pooler do
  use GenServer
  import StockListener.Message

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
    {:noreply, process(update)}
  end

  def process([]) do
  end

  def process([u]) do
    message = u.message

    process_message(message)
    |> send_reply(message.chat.id)

    u.update_id + 1
  end

  defp send_reply("", _) do
  end

  defp send_reply(message, from) do
    {:ok, _} = Nadia.send_message(from, message)
  end

  defp call_itself() do
    Process.send_after(self(), :get_messages, @interval)
  end
end
