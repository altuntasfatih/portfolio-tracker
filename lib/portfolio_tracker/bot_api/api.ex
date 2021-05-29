defmodule PortfolioTracker.Bot.Api do

  @callback get_messages([{atom, any}]) :: any
  @callback send(String.t(),integer()) ::  any
end
