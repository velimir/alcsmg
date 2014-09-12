defmodule Alcsmg.Repository do
  use Ecto.Model
  import Ecto.Query

  schema "repositories" do
    field :url, :string
    has_many :inspections, Alcsmg.Inspection
  end

  def find_by_url(url) do
    q = from r in Alcsmg.Repository, where: r.url == ^url
    Repo.get(q)
  end

  def find_or_create(url) do
    case find_by_url(url) do
      nil ->
        %Alcsmg.Repository{url: url} |> Repo.insert
      obj ->
        obj
    end
  end
end
