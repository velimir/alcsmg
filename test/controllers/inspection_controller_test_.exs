defmodule Alcsmg.InspectionControllerTest do
  use ExUnit.Case
  alias Alcsmg.Router.Helpers
  alias Alcsmg.TestHelpers
  alias Poison, as: JSON

  setup_all do
    resp = send_request
    {:ok, [resp: resp]}
  end

  @obsolete
  test :status_code, %{resp: resp} do
    assert resp.status_code == 201
  end

  defp send_request do
    body = JSON.encode! %{url: "git@github.com:velimir0xff/alcsmg-test.git"}
    :create
    |> Helpers.api_v1_inspection_path
    |> Alcsmg.Endpoint.url
    |> TestHelpers.post(body)
  end
end
