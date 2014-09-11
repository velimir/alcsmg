defmodule Alcsmg.Util do

  def clone(url, callback) do
    dir = System.tmp_dir!
    try do
      clone_to url, dir
      callback.(dir)
    after
      if File.exists?, do: File.rmdir! dir
    end
  end

  def clone_to(url, dst) do
    run! "git", ["clone", url, dst]
  end

  def get_revision(dir) do
    run! "git", ["--git-dir=#{git_dir dir}",
                 "rev-parse",
                 "HEAD"]
  end

  def checkout(dir, revision) do
    run! "git", ["--git-dir='#{git_dir dir}'",
                 "checkout", revision]
  end

  defp git_dir(dir) do
    Path.join dir, ".git"
  end

  def run!(app, args) do
    {:ok, out} = System.cmd app, args
    String.strip out
  end

end
