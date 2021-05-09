defmodule PortfolioTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @env Mix.env()
  use Application

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: PortfolioTracker.Supervisor]
    Supervisor.start_link(children_by_env(@env), opts)
  end

  defp children_by_env(:test) do
    [{PortfolioTracker.CustomSupervisor, :ok}]
  end

  defp children_by_env(_) do
    [
      {PortfolioTracker.CustomSupervisor, :ok},
      # -1 is offset get last message
      {Bot.Pooler, -1}
    ]
  end
end
