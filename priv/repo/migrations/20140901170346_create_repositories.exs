defmodule Repo.Migrations.CreateRepositories do
  use Ecto.Migration

  def up do
    """
      CREATE TABLE repositories(
        id   serial PRIMARY KEY,
        url  text
      )
    """
  end

  def down do
    "DROP TABLE repositories CASCADE"
  end
end
