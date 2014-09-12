use Mix.Config

config :phoenix, Alcsmg.Router,
  port: System.get_env("PORT") || 4000,
  ssl: false,
  host: "localhost",
  cookies: true,
  session_key: "_alcsmg_key",
  session_secret: "YK1XWC_&=QY%&)78D397ZQ%5+HJ7)0U8&N4_UG99^OR&@1OCIM)@YWS2!LM+NT9K*N",
  debug_errors: true

config :phoenix, :code_reloader,
  enabled: true

config :logger, :console,
  level: :debug

config :alcsmg, :db,
  user: :alcsmg,
  pwd: "pwd"
