defmodule Alcsmg.InspectionController do
  use Phoenix.Controller
  alias Alcsmg.Inspection

  plug :action

  def show(conn, %{"id" => id}) do
    case Inspection.find(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json("not found")
      obj ->
        json conn, obj
    end
  end

  def create(conn, %{}) do
    resp = Inspection.check_and_store(
      conn.params["url"],
      conn.params["revision"]
    )

    conn
    |> put_status(:created)
    |> json(resp)
  end
end
