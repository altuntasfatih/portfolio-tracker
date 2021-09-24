import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :logger, :console,
  format: "[$level][$time] $message [$metadata]\n",
  metadata: [:pid, :file, :line]

config :nadia,
  token: System.get_env("BOT_TOKEN")

config :portfolio_tracker, :bist,
  api: PortfolioTracker.Bist.CollectApi,
  collect_api_url: "https://api.collectapi.com/economy/liveBorsa",
  collect_api_token: "apikey 1hMoXHboCriCLsuorHwr0t:54DcwpMehYTRBUvfDQRfFz"

config :portfolio_tracker, :crypto,
  api: PortfolioTracker.Crypto.CoinGeckoApi,
  coin_gecko_api_url: "https://api.coingecko.com"

config :portfolio_tracker,
  backup_path: "./backup/",
  help_file: "./resource/help.md",
  bot_client: PortfolioTracker.Bot.TelegramClient

import_config "#{Mix.env()}.exs"
