import Config

config :stock_listener, :stock_api, StockListener.CollectionApi

import_config "prod.secret.exs"