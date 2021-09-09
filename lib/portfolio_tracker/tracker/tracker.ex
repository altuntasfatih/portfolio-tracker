defmodule PortfolioTracker.Tracker do
  @moduledoc """
  Documentation for `PortfolioTracker`.
  """
  use GenServer
  require Logger
  alias PortfolioTracker.MessageSender

  @api Application.get_env(:portfolio_tracker, :exchange_api)
  @backup_path Application.get_env(:portfolio_tracker, :backup_path)

  def start_link(%Portfolio{} = state) do
    GenServer.start_link(__MODULE__, state, name: {:global, {state.id, __MODULE__}})
  end

  def start_link(id) do
    load_create_state(id)
    |> start_link()
  end

  defp load_create_state(id) do
    case File.read(@backup_path <> "#{id}") do
      {:ok, binary} -> :erlang.binary_to_term(binary)
      _ -> Portfolio.new(id)
    end
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
  def handle_call(:get_alerts, _from, state) do
    {:reply, state.alerts, state}
  end

  @impl true
  def handle_call(:destroy, _from, state) do
    {:stop, :normal, :ok, state}
  end

  @impl true
  def handle_cast(:live, state) do
    new_state = Portfolio.update(state, update_assets_with_live(state.assets))
    :ok = MessageSender.send_message(new_state, state.id)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:set_alert, %Alert{} = alert}, state) do
    {:noreply, Portfolio.add_alert(state, alert)}
  end

  @impl true
  def handle_cast({:add_asset, %Asset{} = asset}, state) do
    {:noreply, Portfolio.add_asset(state, asset)}
  end

  @impl true
  def handle_cast({:delete_asset, asset_name}, state) do
    {:noreply, Portfolio.remove_asset(state, asset_name)}
  end

  @impl true
  def handle_cast({:remove_alert, asset_name}, state) do
    {:noreply, Portfolio.remove_alert(state, asset_name)}
  end

  @impl true
  def handle_cast(:update, state), do: handle_info(:update, state)

  @impl true
  def handle_info(:update, %Portfolio{assets: []} = state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(:update, %Portfolio{assets: assets} = state) do
    {:noreply, Portfolio.update(state, update_assets_with_live(assets))}
  end

  def handle_info(:check_alert, %Portfolio{alerts: []} = state), do: {:noreply, state}

  def handle_info(:check_alert, %Portfolio{alerts: alerts} = state) do
    {hit_list, not_hit_list} = check_alerts_condition(alerts)

    if not (hit_list == []) do
      MessageSender.send_message({:alert_list, hit_list}, state.id)
    end

    {:noreply, %Portfolio{state | alerts: not_hit_list}}
  end

  @impl true
  def handle_info(:take_backup, state) do
    binary = :erlang.term_to_binary(state)

    case File.write(@backup_path <> "#{state.id}", binary) do
      :ok -> Logger.info("State was succefully back up")
      {:error, err} -> Logger.error("Back up failed err -> #{err}")
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:timeout, _) do
    {:stop, :normal, []}
  end

  def check_alerts_condition(alerts) do
    {:ok, current_prices} =
      Enum.map(alerts, fn alert -> alert.asset_name end) |> @api.get_live_prices()

    current_prices =
      Enum.reduce(current_prices, %{}, fn p, acc ->
        Map.put(acc, p.name, p.price)
      end)

    {hit_list, not_hit_list} =
      alerts
      |> Enum.split_with(fn alert ->
        Alert.is_hit(alert, Map.get(current_prices, alert.asset_name))
      end)

    {hit_list, not_hit_list}
  end

  def update_assets_with_live(assets, current_prices) when is_list(assets) do
    Enum.map(assets, fn s ->
      Enum.find(current_prices, fn x -> s.name == x.name end)
      |> calculate_asset(s)
    end)
  end

  defp update_assets_with_live(%{} = assets) do
    {:ok, current_prices} = @api.get_live_prices()

    Map.values(assets)
    |> update_assets_with_live(current_prices)
    |> Enum.reduce(%{}, fn s, acc -> Map.put(acc, s.name, s) end)
  end

  defp calculate_asset(nil, %Asset{} = asset), do: asset
  defp calculate_asset(c, %Asset{} = asset), do: Asset.update(asset, c.price)

  defp take_backup(pid), do: Process.send_after(pid, :take_backup, 1000)

  def get(id), do: via_tuple(id, &GenServer.call(&1, :get))

  def add_asset(%Asset{} = asset, id), do: via_tuple(id, &GenServer.cast(&1, {:add_asset, asset}))

  def set_alert(%Alert{} = alert, id),
    do: via_tuple(id, &GenServer.cast(&1, {:set_alert, alert}))

  def get_alerts(id), do: via_tuple(id, &GenServer.call(&1, :get_alerts))

  def update(id), do: via_tuple(id, &GenServer.cast(&1, :update))

  def live(id), do: via_tuple(id, &GenServer.cast(&1, :live))

  def remove_alert(id, asset_name),
    do: via_tuple(id, &GenServer.cast(&1, {:remove_alert, asset_name}))

  def delete_asset(id, asset_name),
    do: via_tuple(id, &GenServer.cast(&1, {:delete_asset, asset_name}))

  def destroy(id), do: via_tuple(id, &GenServer.call(&1, :destroy))

  def via_tuple(id, callback) do
    case :global.whereis_name({id, __MODULE__}) do
      pid when is_pid(pid) ->
        resp = callback.(pid)
        take_backup(pid)
        resp

      _ ->
        {:error, :portfolio_not_found}
    end
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
