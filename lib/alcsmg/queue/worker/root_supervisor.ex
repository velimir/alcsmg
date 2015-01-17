defmodule Alcsmg.Queue.Worker.RootSupervisor do
	use Supervisor
  @init_worker_number 10

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    children = [
      supervisor(Alcsmg.Queue.Worker.Supervisor, []),
      # TODO: pass number for init workers
      worker(Alcsmg.Queue.Worker.Manager, [%{init_number: get_workers_number}])
    ]

    # TODO: check it, I bet it's not a good approach
    supervise(children, strategy: :one_for_all)
  end

  defp get_workers_number do
    Application.get_env(:alcsmg, :init_work_number, @init_worker_number)
  end
end
