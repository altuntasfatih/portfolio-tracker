defmodule PortfolioTracker.Bot.Client do
  @callback get_messages([{atom, any}]) :: {:ok, [map()]}
  @callback send(String.t(), integer()) :: {:ok, any}
end
