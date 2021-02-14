import Config

config :nadia,
  token: System.get_env("BOT_TOKEN")


import_config "#{config_env()}.exs"
