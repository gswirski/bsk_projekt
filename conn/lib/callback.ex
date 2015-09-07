defmodule Callback do
  use GenServer

  def start_link(conn) do
    GenServer.start_link(__MODULE__, conn, [])
  end

  def handle(pid, msg) do
    GenServer.cast(pid, {:send, elem(msg, 2)})
  end

  def handle_cast({:send, msg}, conn) do
    IO.inspect(msg)
    IO.inspect(conn)
    Connection.send(conn, msg)
    :timer.sleep(1000)
    Connection.send(conn, msg)
    :timer.sleep(1000)
    Connection.send(conn, msg)
    {:noreply, conn}
  end
end
