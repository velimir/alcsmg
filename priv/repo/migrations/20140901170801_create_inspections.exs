defmodule Repo.Migrations.CreateInspections do
  use Ecto.Migration

  def up do
    create table(:inspections) do
      add :repository_id, references(:repositories)
      add :revision,      :text

      timestamps
    end
  end

  def down, do: drop table(:inspections)
end
