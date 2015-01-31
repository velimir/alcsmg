defmodule Alcsmg.Queue.Worker.Manager do
  require Logger
  use GenServer
  alias Alcsmg.Queue.Worker

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    {:ok, args, 0}
  end

  def start_workers(num) do
	  Enum.each :lists.seq(1, num), fn _ -> Worker.Supervisor.start_child([]) end
  end

  def count_worker() do
    Supervisor.count_children(Worker.Supervisor)
  end

  # private

  def handle_info(:timeout, %{init_number: number} = state) do
    Logger.info "starting #{number} check worker(s)"
    start_workers(number)
    Logger.info "#{number} check workers have been started"
    {:noreply, state}
  end
end
