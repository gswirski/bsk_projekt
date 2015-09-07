defmodule Listener do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init([port, module]) do
    {:ok, socket} = :gen_tcp.listen(port, [reuseaddr: true, active: true])
    listen(socket, module)
  end

  def listen(socket, module) do
    IO.puts "listen"

    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Connection.Supervisor, fn ->
      Connection.start_link(client)
    end)
    IO.puts "wtf"
    :ok = :gen_tcp.controlling_process(client, pid)
    GenServer.cast(pid, :start)

    listen(socket, module)
  end
end
