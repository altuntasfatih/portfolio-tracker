import Config

config :nadia,
  token: System.get_env("BOT_TOKEN")

config :stock_listener, :stock_api, StockListener.StockApi

import_config "#{Mix.env()}.exs"
