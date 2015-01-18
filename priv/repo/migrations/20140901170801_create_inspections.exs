defmodule Repo.Migrations.CreateInspections do
  use Ecto.Migration

  def up do
    execute """
      CREATE TABLE inspections(
        id              serial PRIMARY KEY,
        repository_id   integer REFERENCES repositories (id),
        revision        text
      )
    """
  end

  def down do
    execute "DROP TABLE inspections CASCADE"
  end
end
