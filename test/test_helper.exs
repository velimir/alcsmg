ExUnit.start

defmodule Alcsmg.TestHelpers do
  import ExUnit.Assertions

  def test_config,     do: Application.get_env(:alcsmg, :integration_tests)
  def test_repo_owner, do: Dict.get(test_config, :repo_owner, "untruc")
  def test_repo_name,  do: Dict.get(test_config, :repo_name, "alcsmg-test")

  require Logger

  def fixture_path() do
    Path.expand("fixtures", __DIR__)
  end

  def fixture_path(filename) do
    Path.join(fixture_path, filename)
  end

  def fixture(filename) do
    filename
    |> fixture_path
    |> File.read!
  end

  def consult(filename) do
    {:ok, [terms]} =
      filename
      |> fixture_path
      |> :file.consult

    terms
  end

  def check_comments(filename, number) do
    comments =
      number
      |> list_comments
      |> sort_comments

    filename
    |> consult
    |> sort_comments
    |> Enum.zip(comments)
    |> Enum.each(fn {expected, received} ->
        assert map_match?(expected, received),
          "#{inspect expected} not found in #{inspect comments}"
      end
    )
  end

  def map_match?(lh, rh) do
    lh
    |> Dict.keys
    |> Enum.into(%{}, &{&1, get_in(rh, [&1])})
    |> Dict.equal?(lh)
  end

  def prepare_branch(name, parent \\ "master") do
    create_branch(name, get_sha(parent))
    update_files(name)
  end

  def wait_for_status(ref, poll_interval \\ 10_000) do
    case find_status(ref) do
      %{"state" => "pending"} ->
        Logger.debug "PR still in pending, waiting #{inspect poll_interval} ms"
        :timer.sleep(poll_interval)
        wait_for_status(ref, poll_interval)
      resp ->
        Logger.debug "PR status has been changed"
        resp
    end
  end

  def close_pull_request(number) do
    Tentacat.Pulls.update(
      test_repo_owner,
      test_repo_name,
      number,
      %{"state" => "closed"},
      Alcsmg.Github.client
    )
  end

  def create_branch(name, sha) do
    Tentacat.References.create(
      test_repo_owner,
      test_repo_name,
      %{"ref" => "refs/heads/" <> name, "sha" => sha},
      Alcsmg.Github.client
    )
  end

  def create_file(path, filename, branch) do
    Tentacat.Contents.create(
      test_repo_owner,
      test_repo_name,
      path,
      %{
        "message" => "Added file: #{path}",
        "content" => file_content(filename),
        "branch"  => branch
      },
      Alcsmg.Github.client
    )
  end

  def create_pull_request(head, base \\ "master") do
    Tentacat.Pulls.create(
      test_repo_owner,
      test_repo_name,
      %{
        "title" => "testing alcsmg",
        "body"  => "testing alcsmg",
        "head"  => head,
        "base"  => base
      },
      Alcsmg.Github.client
    )
  end

  def delete_branch(name) do
    Tentacat.References.remove(
      test_repo_owner,
      test_repo_name,
      "heads/" <> name,
      Alcsmg.Github.client
    )
  end

  def find_status(ref) do
    Tentacat.Repositories.Statuses.find(
      test_repo_owner,
      test_repo_name,
      ref,
      Alcsmg.Github.client
    )
  end

  def get_branch(name) do
    Tentacat.Repositories.Branches.find(
      test_repo_owner,
      test_repo_name,
      name,
      Alcsmg.Github.client
    )
  end

  def get_sha(branch) do
    resp = Tentacat.References.find(
      test_repo_owner,
      test_repo_name,
      "heads/" <> branch,
      Alcsmg.Github.client
    )

    resp["object"]["sha"]
  end

  def get_tree(sha) do
    Tentacat.Trees.find_recursive(
      test_repo_owner,
      test_repo_name,
      sha,
      Alcsmg.Github.client
    )
  end

  def list_comments(number) do
    Tentacat.Pulls.Comments.list(
      test_repo_owner,
      test_repo_name,
      number,
      Alcsmg.Github.client
    )
  end

  def update_file(path, filename, obj, branch) do
    Tentacat.Contents.update(
      test_repo_owner,
      test_repo_name,
      path,
      %{
        "message" => "Updated file: #{path}",
        "content" => file_content(filename),
        "sha"     => obj["sha"],
        "branch"  => branch
      },
      Alcsmg.Github.client
    )
  end

  defp update_files(branch_name) do
    branch_obj = get_branch(branch_name)
    tree_obj = get_tree(branch_obj["commit"]["commit"]["tree"]["sha"])

    branch_name
    |> get_branch_files
    |> Enum.each(&commit_file(&1, tree_obj, branch_name))
  end

  defp get_branch_files(branch_name) do
    "branches"
    |> Path.join(branch_name)
    |> fixture_path
    |> Path.join("**/*")
    |> Path.wildcard
    |> Enum.filter(&(not File.dir?(&1)))
  end

  defp commit_file(filename, tree, branch) do
    path = file_path(filename, branch)
    case Enum.find(tree["tree"], &match?(%{"path" => ^path}, &1)) do
      nil -> create_file(path, filename, branch)
      obj -> update_file(path, filename, obj, branch)
    end
  end

  defp file_path(path, branch_name) do
    Path.relative_to(path, fixture_path(Path.join("branches", branch_name)))
  end

  defp file_content(filename), do: :base64.encode(File.read!(filename))

  defp sort_comments(comments, keys \\ ~w(path position original_position body)) do
    Enum.sort_by comments, fn comment ->
      for key <- keys, into: %{} do
        {key, Map.get(comment, key)}
      end
    end
  end
end
