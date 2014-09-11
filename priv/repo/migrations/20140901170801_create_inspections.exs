defmodule Repo.Migrations.CreateInspections do
  use Ecto.Migration

  def up do
    """
      CREATE TABLE inspections(
        id        serial PRIMARY KEY,
        repo_id   integer REFERENCES repos (id),
        revision  text
      )
    """
  end

  def down do
    "DROP TABLE inspections CASCADE"
  end
end
