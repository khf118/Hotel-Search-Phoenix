# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :kaligo,
  ecto_repos: [Kaligo.Repo]

# Configures the endpoint
config :kaligo, Kaligo.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UfZx8y2VD6pTYKHLy3zYw92x36oJ+msBBaV2IUD9WFNU2vKy6Y0uOxATuv2ydhS2",
  render_errors: [view: Kaligo.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Kaligo.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
