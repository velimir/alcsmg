defmodule Alcsmg.InspectionController do
  use Phoenix.Controller
  alias Alcsmg.Inspection
  alias Alcsmg.Repository

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
    {:ok, body, conn} = read_body(conn)
    params = JSON.decode! body

    resp = Repository.find_or_create(params["url"])
    |> Inspection.check(params["revision"])
    |> Inspection.insert_with_incidents
    |> JSON.encode!

    json conn, :created, resp
  end
end
