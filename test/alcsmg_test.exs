defmodule AlcsmgTest do
  use ExUnit.Case
  alias Poison, as: JSON

  def base_url do
    env = Application.get_env :phoenix, Alcsmg.Router
    "http://localhost:#{env[:port]}"
  end

  setup_all do
    Application.ensure_all_started :alcsmg
    Alcsmg.Router.start
    HTTPotion.start
    :ok
  end

  test "check without specified revision" do
    headers = [Accept: "application/json",
               "Content-Tyte": "application/json"]
    body = JSON.encode! %{url: "git@github.com:velimir0xff/cache.git"}
    resp = HTTPotion.post "#{base_url}/inspections", body, headers
    assert resp.status_code == 201
    assert resp.body == ""
  end
end
