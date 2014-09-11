defmodule Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres

  def conf do
    parse_url "ecto://postgres:pwd@localhost/alcsmg"
  end

  def priv do
    app_dir(:alcsmg, "priv/repo")
  end
end
