import Config

config :portfolio_tracker,
  bot_client: PortfolioTracker.Bot.MockClient

config :portfolio_tracker, :bist, api: PortfolioTracker.Bist.MockApi
