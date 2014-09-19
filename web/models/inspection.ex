defmodule Alcsmg.Inspection do
  use Ecto.Model

  alias Alcsmg.Checker
  alias Alcsmg.Util

  schema "inspections" do
    field :revision, :string

    belongs_to :repository, Alcsmg.Repository
    has_many :incidents, Alcsmg.Incident
  end

  def check(repo, revision) do
    Util.clone repo.url, fn dir ->
      revision = get_revision dir, revision
      incidents = Checker.check dir
      {%Alcsmg.Inspection{revision: revision, repository_id: repo.id},
       incidents}
    end
  end

  def find(id) do
    Repo.get(from p in Inspection, where: p.id == ^id,
             preload: [:incidents])
  end

  def insert_with_incidents({inspection, incidents}) do
    {:ok, result} = Repo.transaction fn ->
      obj = Repo.insert inspection
      incidents = for incident <- incidents do
        Repo.insert %{incident | inspection_id: obj.id}
      end
      Ecto.Associations.load obj, :incidents, incidents
    end
    result
  end

  defp get_revision(dir, revision) do
    cond do
      revision ->
        Util.checkout dir, revision
      true ->
        Util.get_revision dir
    end
  end
end
