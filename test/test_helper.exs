ExUnit.start
ExUnit.configure(exclude: [obsolete: true])

defmodule Alcsmg.TestHelpers do
  def fixture_path() do
    Path.expand("fixtures", __DIR__)
  end

  def fixture_path(filename) do
    Path.join(fixture_path, filename)
  end

  def post(url, body) do
    HTTPoison.post!(url, body,
                    %{"Accept" => "application/json",
                      "Content-Type" => "application/json"},
                    options)
  end

  def get(url) do
    HTTPoison.get!(url, %{"Accept" => "application/json"}, options)
  end

  defp options, do: [timeout: 30000]
end
