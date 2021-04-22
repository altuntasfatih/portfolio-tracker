import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :nadia,
  token: System.get_env("BOT_TOKEN")

config :portfolio_tracker,
  exchange_api: PortfolioTracker.CollectApi,
  url: "https://api.collectapi.com/economy/liveBorsa",
  token: "apikey 1hMoXHboCriCLsuorHwr0t:54DcwpMehYTRBUvfDQRfFz"

import_config "#{Mix.env()}.exs"
