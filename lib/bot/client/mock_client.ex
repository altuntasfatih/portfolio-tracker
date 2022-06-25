defmodule PortfolioTracker.Bot.MockClient do
  @behaviour PortfolioTracker.Bot.Client

  @impl PortfolioTracker.Bot.Client
  def get_messages(_args), do: {:ok, []}

  @impl PortfolioTracker.Bot.Client
  def send(_message, _to), do: {:ok, nil}
end
