defmodule Alcsmg.InspectionController do
  alias Poison, as: JSON
  use Phoenix.Controller
  alias Alcsmg.Inspection

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
    resp = Inspection.check(conn.params["url"], conn.params["revision"])
    |> Inspection.to_json

    json conn, :created, resp
  end
end
