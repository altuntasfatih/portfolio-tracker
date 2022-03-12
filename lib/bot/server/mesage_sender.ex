defmodule PortfolioTracker.Bot.MessageSender do
  alias PortfolioTracker.{View, Bot.Server}

  def send_message(message, to), do: View.to_str(message) |> Server.send_message(to)
end
