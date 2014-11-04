defmodule AlcsmgTest do
  use ExUnit.Case
  alias Alcsmg.Router.Helpers
  alias Poison, as: JSON

  setup_all do
    Application.ensure_all_started :alcsmg
    Alcsmg.Router.start
    HTTPotion.start
    :ok
  end

  test "check without specified revision" do
    headers = [Accept: "application/json",
               "Content-Type": "application/json"]
    body = JSON.encode! %{url: "git@github.com:velimir0xff/alcsmg-test.git"}
    url = Helpers.url Helpers.api_v1_inspection_path :create
    resp = HTTPotion.post url, body, headers
    assert resp.status_code == 201
    assert resp.body == ""
  end
end
