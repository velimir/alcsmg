defmodule Repo.Migrations.CreateRepositories do
  use Ecto.Migration

  def up do
    execute """
      CREATE TABLE repositories(
        id   serial PRIMARY KEY,
        url  text
      )
    """
  end

  def down do
    execute "DROP TABLE repositories CASCADE"
  end
end
