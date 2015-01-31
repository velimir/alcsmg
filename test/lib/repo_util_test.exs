defmodule Alcsmg.UtilTest do
  use ExUnit.Case, async: true
  alias Alcsmg.Util
  alias Alcsmg.TestHelpers

  defp repo_url do
    owner = Alcsmg.TestHelpers.test_repo_owner
    name = Alcsmg.TestHelpers.test_repo_name
    "git@github.com:#{owner}/#{name}.git"
  end

  test "Util.clone function" do
    {:ok, agent} = Agent.start_link fn -> [] end

    Util.clone repo_url, fn dir ->
      assert File.exists? dir
      Agent.update agent, fn _ -> dir end
    end

    dir = Agent.get agent, fn dir -> dir end
    refute File.exists? dir
  end

  test "checkout change revision" do
    Util.clone repo_url, fn dir ->
      rev_head = Util.get_revision dir
      Util.checkout dir, "HEAD^"
      rev_parent = Util.get_revision dir
      refute rev_head == rev_parent
    end
  end
end
