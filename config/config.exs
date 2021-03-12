import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :nadia,
  token: System.get_env("BOT_TOKEN")

config :stock_listener, :stock_api, StockListener.StockApi

import_config "#{Mix.env()}.exs"
