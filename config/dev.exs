import Config

config :portfolio_tracker,
  bist_api: PortfolioTracker.BistCollectApi,
  url: "https://api.collectapi.com/economy/liveBorsa",
  token: "apikey 1hMoXHboCriCLsuorHwr0t:54DcwpMehYTRBUvfDQRfFz"

import_config "dev.secret.exs"
