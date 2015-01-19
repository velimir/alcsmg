defmodule Repo.Migrations.CreateRepositories do
  use Ecto.Migration

  def up do
    create table(:repositories) do
      add :url, :text

      timestamps
    end
  end

  def down, do: drop table(:repositories)
end
