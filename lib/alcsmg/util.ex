defmodule Alcsmg.Util do

  def clone(url, callback) do
    dir = mktmpdir! System.tmp_dir!
    try do
      clone_to url, dir
      callback.(dir)
    after
      if File.exists? dir do
        File.rm_rf! dir
      end
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
    run! "git", ["--git-dir=#{git_dir dir}",
                 "checkout", revision]
  end

  defp git_dir(dir) do
    Path.join dir, ".git"
  end

  def run!(app, args) do
    {out, 0} = System.cmd app, args
    String.strip out
  end

  defp mktmpdir! dir do
    tmp_dir = random_string 10, 30
    uniq_dir = Path.join dir, tmp_dir
    case File.exists? uniq_dir do
      true -> mktmpdir! dir
      false -> uniq_dir
    end
  end

  defp random_string(min_length, max_length) do
    :random.seed :erlang.now
    chars = String.codepoints("abcdefghijklmnopqrstuvwxyz_12345678910")
    upper = :random.uniform(max_length - min_length) + min_length

    for _ <- 0..upper, into: ""  do
      Enum.at(chars, :random.uniform(Enum.count(chars) - 1))
    end
  end
end
