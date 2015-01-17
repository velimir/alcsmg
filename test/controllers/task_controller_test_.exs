defmodule Alcsmg.TaskControllerTest do
  use ExUnit.Case, async: false

  alias Alcsmg.TestHelpers
  alias Alcsmg.Router.Helpers

  @obsolete
  test "not found task" do
    resp = :show
    |> Helpers.api_v1_task_path(9999)
    |> Alcsmg.Endpoint.url
    |> TestHelpers.get
    assert resp.status_code == 404
    assert resp.body == "\"not found\""
  end
end
