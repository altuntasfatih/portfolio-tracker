import Config

config :portfolio_tracker,
  exchange_api: PortfolioTracker.CollectApi,
  url: "https://api.collectapi.com/economy/liveBorsa",
  token: "apikey 1hMoXHboCriCLsuorHwr0t:54DcwpMehYTRBUvfDQRfFz"

import_config "prod.secret.exs"
