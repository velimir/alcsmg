use Mix.Config

# NOTE: To get SSL working, you will need to set:
#
#     https: true,
#     keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#     certfile: System.get_env("SOME_APP_SSL_CERT_PATH"),
#
# Where those two env variables point to a file on disk
# for the key and cert

config :phoenix, Alcsmg.Router,
  url: [host: "example.com"],
  http: [port: System.get_env("PORT")],
  secret_key_base: "YK1XWC_&=QY%&)78D397ZQ%5+HJ7)0U8&N4_UG99^OR&@1OCIM)@YWS2!LM+NT9K*N"

config :logger, :console,
  level: :info
