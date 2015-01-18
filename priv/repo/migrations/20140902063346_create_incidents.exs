defmodule Repo.Migrations.CreateIncidents do
  use Ecto.Migration

  def up do
    """
      CREATE TABLE incidents(
        id            serial PRIMARY KEY,
        inspection_id integer REFERENCES inspections (id),
        message       text,
        error_type    text,
        path          text,
        line_no       integer,
        column_no     integer,
        msg_id        integer
      )
    """
  end

  def down do
    "DROP TABLE incidents CASCADE"
  end
end
