#defmodule Exper do
  #use Application

  #def start(_type, _args) do
    #import Supervisor.Spec

    #port = 9999

    #children = [
      #supervisor(Task.Supervisor, [[name: Connection.Supervisor]]),
      #worker(Task, [Listener, :start_link, [[port, Connection]]])]

    #opts = [strategy: :one_for_one, name: Exper.Supervisor]
    #Supervisor.start_link(children, opts)
  #end
#end

defmodule Server do
  use GenServer

  def start_link(port) do
    GenServer.start_link(__MODULE__, port, [])
  end

  def init(port) do
    {:ok, socket} = :gen_tcp.listen(port, [active: true])
    GenServer.cast(self(), :accept)
    {:ok, socket}
  end

  def listen(socket) do

  end

  def handle_cast(:accept, state) do
    {:ok, _client} = :gen_tcp.accept(state)
    IO.puts "connected"
    {:noreply, state}
  end

  def handle_call(msg, _from, state) do
    IO.inspect(msg)
    {:noreply, state}
  end

  def handle_cast(msg, state) do
    IO.inspect(msg)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.inspect(msg)
    {:noreply, state}
  end
end

defmodule Exper do
  def start(_type, _args) do
    Server.start_link(9999)
  end
end
