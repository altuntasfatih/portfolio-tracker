import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :logger, :console,
  format: "[$level][$time] $message [$metadata]\n",
  metadata: [:pid, :file, :line]

config :nadia,
  token: System.get_env("BOT_TOKEN")

config :portfolio_tracker, :crypto,
  api: PortfolioTracker.Crypto.CoinGeckoApi,
  coin_gecko_api_url: "https://api.coingecko.com/api/v3/"

config :portfolio_tracker,
  backup_path: "./backup/",
  bot_client: PortfolioTracker.Bot.TelegramClient

import_config "#{Mix.env()}.exs"
