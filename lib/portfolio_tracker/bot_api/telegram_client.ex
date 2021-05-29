defmodule PortfolioTracker.Bot.TelegramClient do
  @behaviour PortfolioTracker.Bot.Api

  @impl true
  def get_messages(args), do: Nadia.get_updates(args)

  @impl true
  def send(message, to), do: send_message(message,to)

  defp send_message("", _), do: {:ok,nil}
  defp send_message({message, args}, to), do: Nadia.send_message(to, message, args)
  defp send_message(message, to), do: {:ok, _} = Nadia.send_message(to, message)
end
