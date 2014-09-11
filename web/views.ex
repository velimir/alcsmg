defmodule Alcsmg.Views do

  defmacro __using__(_options) do
    quote do
      use Phoenix.View
      import unquote(__MODULE__)

      # This block is expanded within all views for aliases, imports, etc
      import Alcsmg.I18n
      import Alcsmg.Router.Helpers
    end
  end

  # Functions defined here are available to all other views/templates
end