import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :bet_unfair, Betunfair.Repo,
  username: "betunfair",
  password: "betunfair",
  database: "betunfair",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bet_unfair, BetunfairWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
