defmodule PortfolioTracker.Bist.MockApi do
  @behaviour PortfolioTracker.Bist.Api

  def start_link do
    Agent.start(fn -> [] end, name: __MODULE__)
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

  def stop(pid), do: Agent.stop(pid)

  @impl true
  def get_price(_) do
    {:ok, pop()}
  end
end
