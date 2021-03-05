defmodule StockListener.MySupervisor do
  use DynamicSupervisor

  def start_link(:ok) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_listener(id) do
    child_spec = {StockListener.Server, id}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      max_restarts: 10
    )
  end

  def children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  def count_children do
    DynamicSupervisor.count_children(__MODULE__)
  end

  @spec termine_child(pid) :: :ok | {:error, :not_found}
  def termine_child(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  def termine_all() do
    children()
    |> Enum.map(fn {_, pid, _, _} -> termine_child(pid) end)
  end
end
