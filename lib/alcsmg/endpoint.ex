defmodule Alcsmg.Endpoint do
  use Phoenix.Endpoint, otp_app: :alcsmg

  # TODO: remove that
  plug Plug.Static,
    at: "/", from: :alcsmg

  plug Plug.Logger

  # Code reloading will only work if the :code_reloader key of
  # the :phoenix application is set to true in your config file.
  plug Phoenix.CodeReloader

  plug Plug.Parsers,
    parsers: [Alcsmg.SaveBodyJson],
    pass: ["application/json"],
    json_decoder: Poison,
    body_save_key: :body

  plug Plug.MethodOverride
  plug Plug.Head

  # TODO: remove that
  plug Plug.Session,
    store: :cookie,
    key: "_alcsmg_key",
    signing_salt: "begfe7Ktr7ddEUBC0n+EgTBeEyljUh8JKJf9XqCJd9kPWktjOTYX/jCHXayjzfEj",
    encryption_salt: "itUj0iA5"

  plug :router, Alcsmg.Router
end
