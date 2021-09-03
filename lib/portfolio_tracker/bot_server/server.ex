defmodule PortfolioTracker.BotServer do
  use GenServer
  require Logger
  alias PortfolioTracker.MessageHandler

  @client Application.get_env(:portfolio_tracker, :bot_client)

  @interval 100
  def start_link(offset) do
    GenServer.start_link(__MODULE__, offset, name: __MODULE__)
  end

  @impl true
  def init(offset) do
    {:ok, offset, {:continue, :call_itself}}
  end

  @impl true
  def handle_cast({:send_message, message, to}, state) do
    {:ok, _} = @client.send(message, to)
    {:noreply, state}
  end

  @impl true
  def handle_info(:get_messages, offset) do
    {:ok, update} = @client.get_messages(offset: offset, limit: 1)
    {:noreply, handle(update, offset), {:continue, :call_itself}}
  end

  @impl true
  def handle_continue(:call_itself, state) do
    Process.send_after(self(), :get_messages, @interval)
    {:noreply, state}
  end

  defp handle([], offset), do: offset
  defp handle([u], _), do: handle(u)

  defp handle(%{message: nil, update_id: id}), do: id + 1

  defp handle(%{message: message, update_id: id}) do
    :ok = MessageHandler.handle_message(message)
    id + 1
  end

  def send_message(message, to) when is_binary(message),
    do: GenServer.cast(__MODULE__, {:send_message, message, to})

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :transient
    }
  end
end
