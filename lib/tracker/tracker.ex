defmodule PortfolioTracker.Tracker do
  @moduledoc """
  Documentation for `PortfolioTracker`.
  """
  use GenServer
  require Logger
  alias PortfolioTracker.Bot.MessageSender

  @bist_api Application.get_env(:portfolio_tracker, :bist)[:api]
  @crypto_api Application.get_env(:portfolio_tracker, :crypto)[:api]
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
  def handle_cast(:live, %Portfolio{assets: assets} = state) when map_size(assets) == 0 do
    {:noreply, state}
  end

  @impl true
  def handle_cast(:live, %Portfolio{} = state) do
    new_state = update_portfolio_with_live(state)
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
  def handle_info(:check_alert, %Portfolio{alerts: []} = state), do: {:noreply, state}

  @impl true
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
      Enum.map(alerts, fn alert -> alert.asset_name end) |> @bist_api.get_live_prices()

    asset_current_prices =
      Enum.reduce(current_prices, %{}, fn asset, acc ->
        Map.put(acc, asset.name, asset.price)
      end)

    {hit_list, not_hit_list} =
      alerts
      |> Enum.split_with(fn alert ->
        Alert.is_hit(alert, Map.get(asset_current_prices, alert.asset_name))
      end)

    {hit_list, not_hit_list}
  end

  def update_portfolio_with_live(%Portfolio{assets: assets} = portfolio) do
    assets =
      split_assets_by_type(assets)
      |> Enum.flat_map(&update_asset_by_type(&1))
      |> Enum.reduce(%{}, fn asset, acc -> Map.put(acc, asset.name, asset) end)

    Portfolio.update(portfolio, assets)
  end

  def split_assets_by_type(%{} = assets) do
    Map.values(assets)
    |> Enum.chunk_by(fn a -> a.type end)
  end

  def update_asset_by_type([%Asset{type: :crypto} | _] = cryptos) do
    {:ok, current_prices} =
      Enum.map(cryptos, fn c -> c.name end)
      |> @crypto_api.get_live_prices()

    get_price = fn name ->
      crypto = Map.get(current_prices, name)
      if crypto != nil, do: crypto.price, else: nil
    end

    Enum.map(cryptos, &calculate_asset(&1, get_price.(&1.name)))
  end

  def update_asset_by_type([%Asset{type: :bist} | _] = stocks) do
    {:ok, current_prices} =
      Enum.map(stocks, fn c -> c.name end)
      |> @bist_api.get_live_prices()

    get_price = fn name ->
      stock = Map.get(current_prices, name)
      if stock != nil, do: stock.price, else: nil
    end

    Enum.map(stocks, &calculate_asset(&1, get_price.(&1.name)))
  end

  defp calculate_asset(%Asset{} = asset, nil), do: asset
  defp calculate_asset(%Asset{} = asset, new_price), do: Asset.update(asset, new_price)

  defp take_backup(pid), do: Process.send_after(pid, :take_backup, 1000)

  def get(id), do: via_tuple(id, &GenServer.call(&1, :get))

  def add_asset(%Asset{type: :crypto} = asset, name) do
    case @crypto_api.look_up(name) do
      {:ok, id} -> via_tuple(id, &GenServer.cast(&1, {:add_asset, asset}))
      {:error, err} -> {:error, err}
    end
  end

  def add_asset(%Asset{type: :bist} = asset, id),
    do: via_tuple(id, &GenServer.cast(&1, {:add_asset, asset}))

  def set_alert(%Alert{} = alert, id),
    do: via_tuple(id, &GenServer.cast(&1, {:set_alert, alert}))

  def get_alerts(id), do: via_tuple(id, &GenServer.call(&1, :get_alerts))

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
