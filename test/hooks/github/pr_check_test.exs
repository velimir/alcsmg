defmodule Alcsmg.Hooks.Github.PrCheckTest do
  import Alcsmg.TestHelpers
	use ExUnit.Case, async: false

  setup_all do
    branch_name = "pr-check"
    prepare_branch(branch_name)
    {_, pr} = create_pull_request(branch_name)
    status = wait_for_status(branch_name)

    on_exit fn ->
      close_pull_request(pr["number"])
      {204, _} = delete_branch(branch_name)
    end

    {:ok, %{status: status, pr: pr}}
  end

  test "pull request status", %{status: status} do
    assert status["state"] == "failure"
    assert status["total_count"] == 1

    st = List.first(status["statuses"])
    assert st["state"] == "error"
    assert st["description"] == "AL Erlang code style check completed with errors"
    assert st["context"] == "code-style/alcsmg"
  end

  test "pull request comments", %{pr: pr} do
    check_comments("comments/pr-check.eterm", pr["number"])
  end
end
