defmodule Bot.Manager do
  use GenServer
  import Bot.MessageConsumer
  require Logger

  @interval 100

  def start_link(offset) do
    GenServer.start_link(__MODULE__, offset, name: __MODULE__)
  end

  @impl true
  def init(offset) do
    call_itself()
    {:ok, offset}
  end

  @impl true
  def handle_cast({:send_message, to, message}, state) do
    {:ok, _} = send_message(to, message)
    {:noreply, state}
  end

  @impl true
  def handle_info(:get_messages, offset) do
    {:ok, update} = Nadia.get_updates(offset: offset, limit: 1)
    call_itself()
    {:noreply, process(update, offset)}
  end

  defp process([], offset), do: offset
  defp process([u], _), do: process(u)

  defp process(%{message: nil, update_id: id}), do: id + 1

  defp process(%{message: message, update_id: id}) do
    consume_message(message)
    |> send_message(message.from.id)

    id + 1
  end

  defp send_message("", _), do: :ok

  defp send_message({message, args}, to),
    do: {:ok, _} = Nadia.send_message(to, message, args)

  defp send_message(message, to), do: {:ok, _} = Nadia.send_message(to, message)

  defp call_itself(), do: Process.send_after(self(), :get_messages, @interval)

  def send_message_user(message, to) when is_binary(message) do
    Logger.info("Send message to user: #{inspect(to)} message: #{inspect(message)}")
    GenServer.cast(__MODULE__, {:send_message, to, message})
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :transient
    }
  end
end
