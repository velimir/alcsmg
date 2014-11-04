defmodule Alcsmg.InspectionController do
  alias Poison, as: JSON
  use Phoenix.Controller
  alias Alcsmg.Inspection
  alias Alcsmg.Repository

  plug :action

  def show(conn, %{"id" => id}) do
    case Inspection.find(id) do
      nil ->
        resp_msg = JSON.encode! "not found"
        json conn, :not_found, resp_msg
      obj ->
        json conn, :ok, JSON.encode! obj
    end
  end

  def create(conn, %{}) do
    resp = Repository.find_or_create(conn.params["url"])
    |> Inspection.check(conn.params["revision"])
    |> Inspection.insert_with_incidents
    |> JSON.encode!

    json conn, :created, resp
  end
end
