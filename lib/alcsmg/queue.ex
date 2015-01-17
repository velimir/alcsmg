defmodule Alcsmg.Queue do
  defdelegate publish_pr(body), to: Alcsmg.Queue.Publisher
end
