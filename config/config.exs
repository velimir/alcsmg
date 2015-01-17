# This file is responsible for configuring your application
use Mix.Config

# Note this file is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project.

config :alcsmg, Alcsmg.Endpoint,
  url: [host: "localhost"],
  http: [port: System.get_env("PORT")],
  secret_key_base: "begfe7Ktr7ddEUBC0n+EgTBeEyljUh8JKJf9XqCJd9kPWktjOTYX/jCHXayjzfEj",
  debug_errors: false

config :alcsmg, Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "alcsmg"

config :alcsmg, :github,
  auth_token: "auth-token"
  # or
  # user: "github_username",
  # password: "p4$$wd"

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :exrabbit,
  host:         "localhost",
  username:     "guest",
  password:     "guest",
  virtual_host: "/",
  heartbeat:    1

config :exrabbit,
  format_options: []

config :phoenix, :serve_endpoints, true
  
# Import environment specific config. Note, this must remain at the bottom of
# this file to properly merge your previous config entries.
import_config "#{Mix.env}.exs"
