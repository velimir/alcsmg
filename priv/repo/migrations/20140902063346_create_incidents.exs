defmodule Repo.Migrations.CreateIncidents do
  use Ecto.Migration

  def up do
    create table(:incidents) do
      add :inspection_id, references(:inspections)
      add :path,          :text
      add :error_type,    :text
      add :msg_id,        :integer
      add :message,       :text
      add :line_no,       :integer
      add :column_no,     :integer, default: 0
    end
  end

  def down, do: drop table(:incidents)
end
