defmodule Alcsmg.Checker do
  alias Alcsmg.Incident

  def check(dir) do
    erl_files(dir)
    |> Enum.map(&check_file/1)
    |> Enum.map(&Incident.from_record/1)
    |> fix_path(dir)
  end

  def erl_files(dir) do
    template = Path.join dir, "**/*.erl"
    Path.wildcard template
  end

  def check_file(file) do
    # TODO: read settings from repository .alcs file
    :alcs.run file, rules: :all
  end

  def fix_path(incidents, dir) do
    Enum.map incidents, &(Path.relative_to &1.path, dir)
  end
end
