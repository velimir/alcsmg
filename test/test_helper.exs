ExUnit.start

defmodule Alcsmg.TestHelpers do
  def fixture_path() do
    Path.expand("fixtures", __DIR__)
  end

  def fixture_path(filename) do
    Path.join(fixture_path, filename)
  end
end
