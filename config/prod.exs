import Config

config :portfolio_tracker,
  stock_api: PortfolioTracker.CollectionApi

config :collection_api,
  url: "https://api.collectapi.com/economy/liveBorsa"
  token: "apikey 1hMoXHboCriCLsuorHwr0t:54DcwpMehYTRBUvfDQRfFz"

import_config "prod.secret.exs"
