defmodule Alcsmg.Queue.Worker do
	require Logger

  alias Alcsmg.Github
  alias Alcsmg.Incident
  alias Alcsmg.Inspection
  alias Alcsmg.GitDiff

  @status_context "code-style/alcsmg"

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

  on %Message{body: body} = msg, state do
    Logger.debug "worker got message to check #{inspect msg}"

    try do
      process_pull_request(body)
    catch
      _, reason ->
        Logger.error "check failed with error: #{inspect reason}"
        on_failed_check(body)
    end

    {:ack, state}
  end

  def process_pull_request(body) do
    number = body["number"]
    repo   = body["repository"]["name"]
    owner  = body["repository"]["owner"]["login"]
    sha    = body["pull_request"]["head"]["sha"]
    url    = body["pull_request"]["head"]["repo"]["ssh_url"]

    incidents =
      body["pull_request"]["url"]
      |> get_diff
      |> check_diff(url, sha)

    comment(incidents, owner, repo, number, sha)

    inspection = store(incidents, url, sha)
    Github.set_status(owner, repo, sha, status_body(inspection, incidents))
  end

  defp on_failed_check(body) do
    repo   = body["repository"]["name"]
    owner  = body["repository"]["owner"]["login"]
    sha    = body["pull_request"]["head"]["sha"]

    Github.set_status(owner, repo, sha, status_body(nil, nil))
  end

  defp get_diff(url) do
    url
    |> Github.get_diff
    |> GitDiff.parse
  end

  defp check_diff(diff, url, sha) do
    %Inspection.CheckResult{
      incidents: all_incidents
    } = Alcsmg.Inspection.check(url, sha)

    all_incidents
    |> Enum.group_by(&find_diff(&1, diff))
    |> Enum.filter(&(not match?({nil, _}, &1)))
  end

  defp comment(incidents, owner, repo, number, sha) do
    comments = Github.list_comments(owner, repo, number)

    incidents
    |> Enum.flat_map(&to_comments(&1, sha))
    |> Enum.filter(&(not comment_exists?(&1, comments)))
    |> Enum.each(&Github.comment_pull_request(owner, repo, number, sha, &1))
  end

  defp store(incidents, url, rev) do
    incidents
    |> Enum.reduce([], fn {_, inc}, acc -> inc ++ acc end)
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

  defp status_body(nil, nil) do
    %{
       "state" => "failure",
       "description" => status_description("failure"),
       "context" => @status_context
     }
  end
  defp status_body(inspection, incidents) do
    state = get_check_state(incidents)
    url = Alcsmg.Router.Helpers.api_v1_inspection_url(
      Alcsmg.Endpoint, :show, inspection.id)

    %{
       "state" => state,
       # TODO: get host name and check id, that's been saved
       "target_url" => url,
       "description" => status_description(state),
       "context" => @status_context
     }
  end

  defp status_description("failure"), do: "AL Erlang code style check failed to complete job"
  defp status_description("success"), do: "AL Erlang code style check completed with no errors"
  defp status_description("error"), do: "AL Erlang code style check completed with errors"

  defp get_check_state(incidnets) do
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
