defmodule Alcsmg.Github do
  require Logger
  
	def client do
    conf = Application.get_env(:alcsmg, :github)
    cond do
      token = conf[:auth_token] ->
        %Tentacat.Client{auth: %{access_token: token}}
      (user = conf[:user]) && (password = conf[:password]) ->
        %Tentacat.Client{auth: %{user: user, password: password}}
    end
  end

  def get_diff(url) do
    Logger.info "retrieving pull request diff for #{url}"
    %HTTPoison.Response{body: body, status_code: 200} = HTTPoison.get!(
      url,
      Tentacat.authorization_header(client) ++
        [{"Accept", "application/vnd.github.v3.diff"}]
    )
    body
  end

  def comment_pull_request(owner, repo, number, sha, body) do
    Logger.info "creating new comment on #{owner}/#{repo}/pull/#{number}##{sha}"
    Logger.debug "body: #{inspect body}"
    {201, _} = Tentacat.Pulls.Comments.create(owner, repo, number, body, client)
  end

  def list_comments(owner, repo, number) do
    Logger.info "retrieving pull request comments #{owner}/#{repo}/pull/#{number}"
    Tentacat.Pulls.Comments.list(owner, repo, number, client)
  end

  def set_status(owner, repo, sha, body) do
    Logger.info "setting status for repos/#{owner}/#{repo}/statuses/#{sha}"
    Logger.debug "body: #{inspect body}"
    {201, _} = Tentacat.Repositories.Statuses.create(owner, repo, sha, body, client)
  end 
end
