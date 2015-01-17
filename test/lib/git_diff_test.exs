defmodule GitDiffTest do
  use ExUnit.Case, async: true
  alias Alcsmg.TestHelpers

  setup context do
    "test " <> name = context.test |> to_string
    diff = TestHelpers.fixture_path(name <> ".diff") |> File.read!
    {:ok, [parsed]} = :file.consult(TestHelpers.fixture_path(name <> ".parsed"))
    
    {:ok,
     context
     |> Map.put(:diff, diff)
     |> Map.put(:parsed, parsed)}
  end

  test "simple", context, do: test_parse(context)
  test "multiple", context, do: test_parse(context)

  defp test_parse(context) do
	  assert Alcsmg.GitDiff.parse(context.diff) == context.parsed
  end
end
