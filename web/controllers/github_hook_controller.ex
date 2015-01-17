defmodule Alcsmg.GithubHookController do
  use Phoenix.Controller
  require Logger

  plug :action

  @events ~w(pull_request)

  # TODO: take care of uniqie X-Github-Delivery in order to avoid
  # processing the same requests
  # TODO: make sure that request has been sent from github (detect by
  # IP? / add secret suport)
  def create(conn, hook_data) do
    [event] = get_req_header(conn, "x-github-event")
    on_event(conn, hook_data, event)
  end

  defp on_event(conn, _data, event) when event in @events do
    Alcsmg.Queue.publish_pr(conn.private[:body])
    conn |> put_status(:created) |> json(:created)
  end
  defp on_event(conn, data, "ping") do
	  Logger.info "we've been pinged"
    json conn, data
  end
  defp on_event(conn, _data, event) do
    Logger.info "received unsupported event: #{inspect event}"
    conn
    |> put_status(:bad_request)
    |> json(%{:error => "event '#{inspect event}' is not supported"})
  end
end
