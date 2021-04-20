import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :nadia,
  token: System.get_env("BOT_TOKEN")

config :portfolio_tracker,
  stock_api: PortfolioTracker.StockApi


import_config "#{Mix.env()}.exs"
