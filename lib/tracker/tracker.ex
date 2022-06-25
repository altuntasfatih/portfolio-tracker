defmodule PortfolioTracker.Tracker do
  @moduledoc """
  Documentation for `PortfolioTracker`.
  """
  use GenServer
  alias PortfolioTracker.Bot.MessageSender
  alias PortfolioTracker.{Crypto, Repo}

  def start_link(%Portfolio{} = state) do
    GenServer.start_link(__MODULE__, state, name: {:global, {state.id, __MODULE__}})
  end

  def start_link(id) do
    Repo.get(id)
    |> start_link()
  end

  @impl true
  def init(%Portfolio{} = p), do: {:ok, p}

  @impl true
  def handle_call(:get, _from, %Portfolio{} = p), do: {:reply, {:ok, p}, p}

  @impl true
  def handle_call(:get_alerts, _from, %Portfolio{} = p), do: {:reply, {:ok, p.alerts}, p}

  @impl true
  def handle_call(:destroy, _from, %Portfolio{} = p) do
    # remove from backup
    {:stop, :normal, :ok, p}
  end

  @impl true
  def handle_cast(:live, %Portfolio{} = p) do
    new_portfolio = update_portfolio_with_live(p)
    send_message(new_portfolio, new_portfolio.id)

    {:noreply, new_portfolio}
  end

  @impl true
  def handle_cast({:set_alert, %Alert{} = alert}, %Portfolio{} = p) do
    {:noreply, Portfolio.add_alert(p, alert)}
  end

  @impl true
  def handle_cast({:add_asset, %Asset{name: name} = asset}, %Portfolio{} = p) do
    case Crypto.Api.look_up(name) do
      {:ok, id} ->
        new_portfolio =
          Portfolio.add_asset(p, %Asset{
            asset
            | id: id,
              name: name
          })

        {:noreply, new_portfolio}

      err ->
        send_message(err, p.id)
        {:noreply, p}
    end
  end

  @impl true
  def handle_cast({:delete_asset, asset_name}, %Portfolio{} = p) do
    {:noreply, Portfolio.remove_asset(p, asset_name)}
  end

  @impl true
  def handle_cast({:remove_alert, asset_name}, %Portfolio{} = p) do
    {:noreply, Portfolio.remove_alert(p, asset_name)}
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
    Repo.save(state.id, state)
    {:noreply, state}
  end

  @impl true
  def handle_info(:timeout, _) do
    {:stop, :normal, []}
  end

  defp send_message(message, to) do
    :ok = MessageSender.send_message(message, to)
  end

  def check_alerts([%Alert{asset_type: :crypto} | _] = alerts) do
    current_price =
      Enum.map(alerts, fn a -> a.asset_id end)
      |> get_crypto_prices()

    alerts
    |> Enum.split_with(fn alert ->
      Alert.is_hit(alert, current_price.(alert.asset_id))
    end)
  end

  def check_alerts_condition(alerts) do
    Enum.chunk_by(alerts, fn a -> a.asset_type end)
    |> Enum.map(&check_alerts(&1))
    |> Enum.reduce({[], []}, fn {hit_list, not_hit_list}, {hit_acc, not_hit_acc} ->
      {hit_list ++ hit_acc, not_hit_list ++ not_hit_acc}
    end)
  end

  def get_crypto_prices(asset_ids) do
    {:ok, current_prices} = asset_ids |> Crypto.Api.get_price()

    fn id ->
      crypto = Map.get(current_prices, id)
      if crypto != nil, do: crypto.price, else: nil
    end
  end

  defp update_portfolio_with_live(%Portfolio{assets: assets} = portfolio) do
    assets =
      Map.values(assets)
      |> Enum.chunk_by(fn a -> a.type end)
      |> Enum.flat_map(&update_asset_by_type(&1))
      |> Enum.reduce(%{}, fn asset, acc -> Map.put(acc, asset.name, asset) end)

    Portfolio.update(portfolio, assets)
  end

  defp update_asset_by_type([%Asset{type: :crypto} | _] = cryptos) do
    get_price =
      Enum.map(cryptos, fn c -> c.id end)
      |> get_crypto_prices()

    Enum.map(cryptos, &calculate_asset(&1, get_price.(&1.id)))
  end

  defp calculate_asset(%Asset{} = asset, nil), do: asset
  defp calculate_asset(%Asset{} = asset, new_price), do: Asset.update(asset, new_price)

  defp take_backup(pid), do: Process.send_after(pid, :take_backup, 1000)

  def get(id), do: via_tuple(id, &GenServer.call(&1, :get))

  def add_asset(%Asset{} = asset, id),
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
