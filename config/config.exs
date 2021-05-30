import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :logger, :console,
  format: "[$level][$time] $message [$metadata]\n",
  metadata: [:pid, :file, :line]

config :nadia,
  token: System.get_env("BOT_TOKEN")

config :portfolio_tracker,
  exchange_api: PortfolioTracker.CollectApi,
  bot_client: PortfolioTracker.Bot.TelegramClient,
  url: "https://api.collectapi.com/economy/liveBorsa",
  token: "apikey 1hMoXHboCriCLsuorHwr0t:54DcwpMehYTRBUvfDQRfFz"

config :portfolio_tracker,
  backup_path: "./backup/",
  help_file: "./resource/help.md"

import_config "#{Mix.env()}.exs"
