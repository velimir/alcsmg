defmodule Alcsmg.Queue.Supervisor do
	use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    children = [
      worker(Alcsmg.Queue.Publisher, []),
      supervisor(Alcsmg.Queue.Worker.RootSupervisor, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
