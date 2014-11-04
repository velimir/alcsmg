defmodule Alcsmg.UtilTest do
  use ExUnit.Case, async: true
  alias Alcsmg.Util

  test "Util.clone function" do
    {:ok, agent} = Agent.start_link fn -> [] end

    url = "git@github.com:velimir0xff/alcsmg-test.git"
    Util.clone url, fn dir ->
      assert File.exists? dir
      Agent.update agent, fn _ -> dir end
    end

    dir = Agent.get agent, fn dir -> dir end
    refute File.exists? dir
  end

  test "checkout change revision" do
    url = "git@github.com:velimir0xff/alcsmg-test.git"
    Util.clone url, fn dir ->
      rev_head = Util.get_revision dir
      Util.checkout dir, "HEAD^"
      rev_parent = Util.get_revision dir
      refute rev_head == rev_parent
    end
  end
end
