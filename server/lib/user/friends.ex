defmodule User.Friends do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %User.HandlerState{}, [])
  end

  def add(friends, sender) do
    GenServer.cast(friends, {:add, sender})
  end

  def handle_cast({:add, sender}, state) do
    %User.HandlerState{receiver: receiver, c_seq: c_seq} = state

    if c_seq == -1 do
      :timer.sleep(1000)
      User.Friends.send(self(), sender)
      {:noreply, state}
    else
      der_key = User.fetch(sender, :der_key)
      name = User.fetch(sender, :name)
      conn = User.fetch(receiver, :conn)
      msg = 'c#{c_seq} friend\n#{name} #{der_key}\n'
      Kernel.send(conn, {:send, msg})
      {:noreply, state}
    end
  end

  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end
end
