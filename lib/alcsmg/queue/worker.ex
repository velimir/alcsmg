defmodule Alcsmg.Queue.Worker do
	require Logger

  alias Alcsmg.Github
  alias Alcsmg.Incident
  alias Alcsmg.Inspection
  alias Alcsmg.GitDiff

  use GenServer
  use Exrabbit.Consumer.DSL,
    exchange: exchange_declare(
      exchange: "pull_request", type: "direct", durable: true
    ),
    queue: queue_declare(
      queue: "check.style", durable: true
    ),
    binding_key: "pr.check.style",
    conn_opts: [qos: basic_qos(prefetch_count: 1)],
    no_ack: false,
    format: :json

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  init [] do
    {:ok, []}
  end

  # TODO: refactor it
  # TODO: spawn a process and catch all error
  on %Message{body: body} = msg, state do
    Logger.debug "worker got message to check #{inspect msg}"
    number = body["number"]
    repo   = body["repository"]["name"]
    owner  = body["repository"]["owner"]["login"]
    sha    = body["pull_request"]["head"]["sha"]
    url    = body["pull_request"]["head"]["repo"]["ssh_url"]

    diff = Github.get_diff(body["pull_request"]["url"]) |> GitDiff.parse

    %Inspection.CheckResult{
      incidents: all_incidents
    } = Alcsmg.Inspection.check(url, sha)

    incidents =
      all_incidents
      |> Enum.group_by(&find_diff(&1, diff))
      |> Enum.filter(&(not match?({nil, _}, &1)))

    inspection = store(incidents, url, sha)

    comments = Github.list_comments(owner, repo, number)

    incidents
    |> Enum.flat_map(&to_comments(&1, sha))
    |> Enum.filter(&(not comment_exists?(&1, comments)))
    |> Enum.each(&Github.comment_pull_request(owner, repo, number, sha, &1))

    Github.set_status(owner, repo, sha, status_body(inspection, incidents))

    {:ack, state}
  end

  defp store(incidents, url, rev) do
    Enum.reduce(incidents, [], fn {_, inc}, acc -> inc ++ acc end)
    |> Inspection.insert(url, rev)
  end

  defp find_diff(%Incident{line_no: line_no, path: path}, diff_list) do
    case Enum.find(diff_list, &match?(%GitDiff{to: ^path}, &1)) do
      %GitDiff{lines: lines} = diff ->
        cond do
          Enum.any?(lines, &match?(%GitDiff.Code{ln: ^line_no, type: :added}, &1)) -> diff
          true -> nil
        end
      _ ->
        nil
    end
  end

  defp status_body(inspection, incidents) do
    %{
       "state" => get_check_status(incidents),
       # TODO: get host name and check id, that's been saved
       "target_url" => Alcsmg.Router.Helpers.api_v1_inspection_url(Alcsmg.Endpoint, :show, inspection.id),
       "description" => "AL Erlang code style check",
       "context" => "code-style/alcsmg"
     }
  end

  defp get_check_status(incidnets) do
    cond do
      Enum.any? incidnets, &match?({diff, _} when diff != nil, &1) -> "error"
      true -> "success"
    end
  end

  defp to_comments({diff, incidents}, commit_id) do
    for incident <- incidents, do: comment_body(diff, incident, commit_id)
  end

  defp comment_body(%GitDiff{to: path} = diff, incident, commit_id) do
    %{
       "commit_id" => commit_id,
       "path"      => path,
       "position"  => position_in_diff(diff, incident),
       "body"      => comment_msg(incident)
     }
  end

  defp position_in_diff(%GitDiff{lines: lines}, %Incident{line_no: line_no}) do
    {_diff, position} =
      lines
      |> Enum.with_index
      |> Enum.find(&match?({%GitDiff.Code{ln: ^line_no}, _}, &1))
    position + 1
  end

  defp comment_msg(%Incident{msg_id: msg_id, error_type: type, message: msg}) do
    "#{type} detected: #{msg} (see code style: #{msg_id})"
  end

  defp comment_exists?(%{"body" => body, "position" => position}, comments) do
    Enum.any? comments, &match?(%{"body" => ^body, "position" => ^position}, &1)
  end
end
