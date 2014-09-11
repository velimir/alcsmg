defmodule Alcsmg.Router do
  use Phoenix.Router

  scope alias: Alcsmg do
    get "/", WelcomeController, :index, as: :root
    resources "/inspections", InspectionController, only: [:show, :create]
  end
end
