use Mix.Config

config :phoenix, Alcsmg.Router,
  port: System.get_env("PORT") || 4001,
  ssl: false,
  cookies: true,
  session_key: "_alcsmg_key",
  session_secret: "YK1XWC_&=QY%&)78D397ZQ%5+HJ7)0U8&N4_UG99^OR&@1OCIM)@YWS2!LM+NT9K*N"

config :phoenix, :code_reloader,
  enabled: true

config :logger, :console,
  level: :debug


