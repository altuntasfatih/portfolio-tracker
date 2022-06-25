defmodule PortfolioTracker.Bot.TelegramClient do
  @behaviour PortfolioTracker.Bot.Client

  @impl PortfolioTracker.Bot.Client
  def get_messages(args), do: Nadia.get_updates(args)

  @impl PortfolioTracker.Bot.Client
  def send(message, to), do: send_message(message, to)

  defp send_message("", _), do: {:ok, nil}
  defp send_message({message, args}, to), do: Nadia.send_message(to, message, args)
  defp send_message(message, to), do: {:ok, _} = Nadia.send_message(to, message)
end
