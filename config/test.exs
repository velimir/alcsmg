use Mix.Config

config :alcsmg, Alcsmg.Endpoint,
  http: [port: System.get_env("PORT") || 4001]
