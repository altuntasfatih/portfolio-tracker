defmodule PortfolioTracker.MockExchangeApi do
  @behaviour PortfolioTracker.ExchangeApi

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def push(expected_response) do
    Agent.update(__MODULE__, fn state ->
      [expected_response | state]
    end)
  end

  def pop do
    Agent.get_and_update(__MODULE__, fn state ->
      case state do
        [response | tail] -> {response, tail}
        _ -> {[], state}
      end
    end)
  end

  @impl true
  def get_live_prices() do
    {:ok, pop()}
  end

  @impl true
  def get_live_prices(_) do
    {:ok, pop()}
  end
end
