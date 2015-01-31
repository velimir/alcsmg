defmodule Alcsmg.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ~w(json)
  end

  scope path: "/api/alcs/v1", alias: Alcsmg, as: :api_v1 do
    pipe_through :api

    resources "/inspections", InspectionController, only: [:show, :create]
    post      "/github-webhook", GithubHookController, :create
  end
end
