defmodule Repo do
  use Ecto.Repo,
    otp_app: :alcsmg,
    adapter: Ecto.Adapters.Postgres
end
