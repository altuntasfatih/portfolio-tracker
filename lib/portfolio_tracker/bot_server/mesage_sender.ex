defmodule PortfolioTracker.MessageSender do
  alias PortfolioTracker.{View, BotServer}

  def send_message(message, to), do: View.to_string(message) |> BotServer.send_message(to)
end
