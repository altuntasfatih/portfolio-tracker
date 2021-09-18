defmodule PortfolioTracker.Bot.MessageSender do
  alias PortfolioTracker.{View, Bot.Server}

  def send_message({message, args}, to),
    do: Server.send_message({View.to_string(message), args}, to)

  def send_message(message, to), do: View.to_string(message) |> Server.send_message(to)
end
