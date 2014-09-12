defmodule Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres, env: Mix.env

  def conf(env), do: parse_url url(env)

  def priv do
    app_dir(:alcsmg, "priv/repo")
  end

  defp url(env) do
    conf = Application.get_env :alcsmg, :db
    uri = "ecto://#{cred conf}@#{conf[:address]}/#{conf[:db_name]}"
    args = conf[:args]
    cond do
      args -> uri <> "?" <> URI.encode_query(args)
      true -> uri
    end
  end

  defp cred(conf) do
    "#{conf[:user]}:#{conf[:pwd]}"
  end
end
