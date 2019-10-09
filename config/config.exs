import Config

config :gmail, :thread, pool_size: 100
config :gmail, :message, pool_size: 100

import_config("~/.baconmail.exs")
