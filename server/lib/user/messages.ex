defmodule User.Messages do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %User.HandlerState{}, [])
  end

  def send(messages, sender, content) do
    GenServer.cast(messages, {:send, sender, content})
  end

  def handle_cast({:send, sender, content}, state) do
    %User.HandlerState{receiver: receiver, c_seq: c_seq} = state

    if c_seq == -1 do
      :timer.sleep(1000)
      User.Messages.send(self(), sender)
      {:noreply, state}
    else
      name = User.fetch(sender, :name)
      conn = User.fetch(receiver, :conn)
      msg = 'c#{c_seq} message\n#{name} #{content}\n'
      Kernel.send(conn, {:send, msg})
      {:noreply, state}
    end
  end

  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end
end
