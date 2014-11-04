defmodule Alcsmg.Mixfile do
  use Mix.Project

  def project do
    [ app: :alcsmg,
      version: "0.0.1",
      elixir: "~> 1.0",
      elixirc_paths: ["lib", "web"],
      compilers: [:phoenix] ++ Mix.compilers,
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [
      mod: { Alcsmg, [] },
      applications: [:phoenix, :cowboy, :logger, :postgrex, :ecto]
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [
      {:phoenix,  "0.5.0"},
      {:cowboy,   "~> 1.0.0"},
      {:postgrex, "~> 0.6"},
      {:ecto,     "~> 0.2"},
      {:inflex,   "~> 0.2.9"},
      {:alcs, git: "git@bitbucket.org:velimir/alcs.git"},
      # test dependencies
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.1", only: :test},
      {:httpotion, "~> 0.2.4", only: :test}
    ]
  end
end
