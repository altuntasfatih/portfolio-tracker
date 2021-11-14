defmodule PortfolioTracker.Bot.MessageSender do
  alias PortfolioTracker.{View, Bot.Server}

  def send_message({message, args}, to),
    do: Server.send_message({View.to_str(message), args}, to)

  def send_message(message, to), do: View.to_str(message) |> Server.send_message(to)
end
