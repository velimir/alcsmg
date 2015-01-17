defmodule Alcsmg.Queue.Publisher do
  require Logger
  
	use GenServer
  use Exrabbit.Records
  alias Exrabbit.Producer

  @call_timeout :timer.minutes(60)

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Logger.info "creating publisher"

    exchange = exchange_declare(
      exchange: "pull_request", type: "direct", durable: true
    )

    producer = %Producer{chan: chan} = Producer.new(
      exchange: exchange, format: nil
    )    
    Exrabbit.Channel.set_mode(chan, :confirm)
    
    {:ok, %{producer: producer}}
  end

  def publish_pr(body) do
    GenServer.call(__MODULE__, {:publish_pr, body}, @call_timeout)
  end

  def terminate(reason, %{producer: producer}) do
    Logger.info "publisher is going to be terminated right now with a reason: #{inspect reason}"
    Producer.shutdown(producer)
  end

  def handle_call({:publish_pr, body}, _from, %{producer: producer} = state) do
    Logger.debug "publishing pull request body"
    msg = %Exrabbit.Message{
      body: body,
      # make message persistent
      props: pbasic(delivery_mode: 2)
    }
    Producer.publish(producer, msg, routing_key: "pr.check.style",
                     await_confirm: true)
    Logger.debug "published"
    {:reply, :ok, state}
  end
end
