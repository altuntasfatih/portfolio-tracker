defmodule StockListener do
  @moduledoc """
  Documentation for `StockListener`.
  """
  use GenServer
  require Logger

  def start_link({initial_state, id}) do
    GenServer.start_link(__MODULE__, initial_state, name: {:global, {id, __MODULE__}})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:decode, _}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(:timeout, _) do
    {:stop, :normal, []}
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :transient,
      shutdown: 500
    }
  end
end
