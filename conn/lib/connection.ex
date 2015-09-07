defmodule Connection do
  defmodule Data do
    defstruct socket: nil, callback: nil
  end

  use GenServer

  def start_link(socket) do
    {:ok, conn} = GenServer.start_link(__MODULE__, %Data{socket: socket}, [])
    {:ok, callback} = Callback.start_link(conn)
    Connection.set_callback(conn, callback)
    {:ok, conn}
  end

  def set_callback(conn, callback) do
    GenServer.call(conn, {:set_callback, callback})
  end

  def send(conn, msg) do
    GenServer.cast(conn, {:send, msg})
  end

  def handle_cast({:send, msg}, state) do
    :gen_tcp.send(state.socket, msg)
    {:noreply, state}
  end

  def handle_call({:set_callback, callback}, _from, state) do
    {:reply, :ok, %{state | callback: callback}}
  end

  def handle_info(msg, state) do
    IO.inspect(state)
    Callback.handle(state.callback, msg)
    {:noreply, state}
  end
end
