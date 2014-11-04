defmodule Alcsmg.Router do
  use Phoenix.Router

  scope path: "/api/alcs/v1", alias: Alcsmg, as: :api_v1 do
    pipe_through :api

    resources "/inspections", InspectionController, only: [:show, :create]
  end
end
