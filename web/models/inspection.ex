defmodule Alcsmg.Inspection do
  use Ecto.Model

  import Ecto.Query, only: [from: 2]

  alias Alcsmg.Util
  alias Alcsmg.Checker

  schema "inspections" do
    field :repo_id,  :integer
    field :revision, :string

    belongs_to :repository, Alcsmg.Repository
    has_many :incidents, Alcsmg.Incident
  end

  def check(repo, revision) do
    Util.clone repo.url, fn dir ->
      revision = unless revision do
        Util.get_revision dir
      end
      # add checkout
      incidents = Checker.check dir
      %Inspection{revision: revision,
                  repo_id: repo.id,
                  incidents: incidents}
    end
  end

  def find(id) do
    Repo.get(from p in Inspection, where: p.id == ^id,
             preload: [:incidents])
  end

  def insert_with_assoc(obj) do
    Repo.transaction fn ->
      obj = Repo.insert obj
      incidents = for incident <- obj.incidents do
        Repo.insert %{incident | inspection_id: obj.id}
      end
      %{obj | incidents: incidents}
    end
  end
end
