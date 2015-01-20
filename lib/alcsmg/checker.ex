defmodule Alcsmg.Checker do
  require Logger
  alias Alcsmg.Incident

  def check(dir) do
    erl_files(dir)
    |> Enum.map(&check_file/1)
    |> List.flatten
    |> Enum.map(&Incident.from_record/1)
    |> fix_path(dir)
  end

  def erl_files(dir) do
    template = Path.join dir, "**/*.erl"
    Path.wildcard template
  end

  def check_file(file) do
    # TODO: read settings from repository .alcs file
    Logger.debug "running check on file: #{file}"
    :alcs.run(to_char_list(file), rules: :all)
    |> Enum.filter(&(&1 != :ok))
  end

  def fix_path(incidents, dir) do
    Enum.map incidents, &(%{&1 | path: Path.relative_to(&1.path, dir)})
  end
end
