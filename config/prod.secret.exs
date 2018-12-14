use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :blockchain, BlockchainWeb.Endpoint,
  secret_key_base: "WWqCW0RYnH/egbMNOxC431ORhkkuaJ0ew7g9mifaMvXeoFO3Za7IOyX/gsPZmmTK"

# Configure your database
#config :blockchain, Blockchain.Repo,
#  username: "postgres",
#  password: "postgres",
#  database: "blockchain_prod",
#  pool_size: 15
