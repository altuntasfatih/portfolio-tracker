import Config

config :portfolio_tracker,
  exchange_api: PortfolioTracker.MockExchangeApi,
  bot_client: PortfolioTracker.Bot.MockClient
