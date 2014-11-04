defmodule Alcsmg.InspectionControllerTest do
  use ExUnit.Case
  alias Alcsmg.Router.Helpers
  alias Poison, as: JSON

  setup_all do
    start_apps
    resp = send_request
    {:ok, [resp: resp]}
  end

  test :status_code, %{resp: resp} do
    assert resp.status_code == 201
  end

  defp start_apps do
	  Application.ensure_all_started :alcsmg
    Alcsmg.Router.start
    HTTPotion.start
  end

  defp send_request do
	  headers = [Accept: "application/json",
               "Content-Type": "application/json"]
    body = JSON.encode! %{url: "git@github.com:velimir0xff/alcsmg-test.git"}
    url = Helpers.url Helpers.api_v1_inspection_path :create
    HTTPotion.post url, body, headers, timeout: 30000
  end
end
