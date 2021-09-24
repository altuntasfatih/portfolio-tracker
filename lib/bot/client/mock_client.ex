defmodule PortfolioTracker.Bot.MockClient do
  @behaviour PortfolioTracker.Bot.Client

  @impl true
  def get_messages(_args), do: {:ok, []}

  @impl true
  def send(_message, _to), do: {:ok, nil}
end
