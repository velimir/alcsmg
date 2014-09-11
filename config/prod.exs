use Mix.Config

# NOTE: To get SSL working, you will need to set:
#
#     ssl: true,
#     keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#     certfile: System.get_env("SOME_APP_SSL_CERT_PATH"),
#
# Where those two env variables point to a file on disk
# for the key and cert

config :phoenix, Alcsmg.Router,
  port: System.get_env("PORT"),
  ssl: false,
  host: "example.com",
  cookies: true,
  session_key: "_alcsmg_key",
  session_secret: "YK1XWC_&=QY%&)78D397ZQ%5+HJ7)0U8&N4_UG99^OR&@1OCIM)@YWS2!LM+NT9K*N"

config :logger, :console,
  level: :info,
  metadata: [:request_id]

