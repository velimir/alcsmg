defmodule Alcsmg.Queue.Worker.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    children = [worker(Alcsmg.Queue.Worker, [])]
    supervise(children, strategy: :simple_one_for_one)
  end

  def start_child(args) do
    Supervisor.start_child(__MODULE__, args)
  end
end
