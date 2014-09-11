defmodule Alcsmg.Repository do
  use Ecto.Model

  import Ecto.Query, only: [from: 2]

  schema "repositories" do
    field :url, :string
    has_many :inspections, Alcsmg.Inspection
  end

  def find_by_url(url) do
    Repo.get(from r in Repository, where r.url == ^url)
  end

  def find_or_create(url) do
    case find_by_url(url) do
      nil ->
        %Repository{url: url} |> Repo.insert
      obj ->
        obj
    end
  end
end
