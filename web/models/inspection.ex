defmodule Alcsmg.Inspection do
  defmodule CheckResult, do: defstruct url: nil, rev: nil, incidents: []

  use Ecto.Model

  alias Alcsmg.Checker
  alias Alcsmg.Util
  alias Alcsmg.Repository

  schema "inspections" do
    field :revision, :string

    timestamps

    belongs_to :repository, Alcsmg.Repository
    has_many :incidents, Alcsmg.Incident
  end

  def check(url, rev) do
    Util.clone url, fn dir ->
      %CheckResult{
        url: url,
        rev: get_revision(dir, rev),
        incidents: Checker.check(dir)
      }
    end
  end

  def check_and_store(url, revision) do
    %CheckResult{rev: rev, incidents: incidents} = check(url, revision)
    insert(incidents, url, rev)
  end

  def insert(incidents, url, rev) do
    repo = Repository.find_or_create(url)
    insert_with_incidents(%Alcsmg.Inspection{revision: rev, repository_id: repo.id}, incidents)
  end

  def insert_with_incidents(inspection, incidents) do
    {:ok, result} = Repo.transaction fn ->
      obj = Repo.insert inspection
      incidents = for incident <- incidents do
        Repo.insert %{incident | inspection_id: obj.id}
      end
      %{obj | incidents: incidents}
    end
    result
  end

  def find(id) do
    Repo.get(from p in Inspection, where: p.id == ^id,
             preload: [:incidents])
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
