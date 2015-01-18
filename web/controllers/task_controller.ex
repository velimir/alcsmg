defmodule Alcsmg.TaskController do
  defmodule NotFound do
    defexception plug_status: 404, message: "no task found"
  end

  use Phoenix.Controller
  alias Alcsmg.InspectionTask

  plug :action

  def show(conn, %{"id" => id}) do
    case Integer.parse(id) do
      {id, ""} ->
        case InspectionTask.find(id) do
          nil -> raise NotFound
          obj -> json conn, obj
        end
      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{"error" => "id should be integer"})
    end
  end
end
