# This file is responsible for configuring your application
use Mix.Config

# Note this file is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project.

config :phoenix, Alcsmg.Router,
  port: System.get_env("PORT"),
  ssl: false,
  static_assets: true,
  cookies: true,
  session_key: "_alcsmg_key",
  session_secret: "YK1XWC_&=QY%&)78D397ZQ%5+HJ7)0U8&N4_UG99^OR&@1OCIM)@YWS2!LM+NT9K*N",
  catch_errors: true,
  debug_errors: false,
  error_controller: Alcsmg.PageController

config :phoenix, :code_reloader,
  enabled: false

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. Note, this must remain at the bottom of
# this file to properly merge your previous config entries.
import_config "#{Mix.env}.exs"
