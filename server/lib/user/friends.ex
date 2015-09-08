defmodule User.Friends do
  defmodule State do
    defstruct receiver: nil, c_seq: -1, friends: []
  end

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %State{}, [])
  end

  def add(friends, sender) do
    GenServer.cast(friends, {:add, sender})
  end

  def flush(friends) do
    GenServer.cast(friends, :flush)
  end

  def handle_cast(:flush, state) do
    IO.puts "flush"
    %State{receiver: receiver, c_seq: c_seq, friends: friends} = state
    if c_seq == -1 do
      IO.puts "sleeping"
      :timer.sleep(1000)
      GenServer.cast(self(), :flush)
      {:noreply, state}
    else
      conn = User.fetch(receiver, :conn)

      for friend <- friends do
        der_key = User.fetch(friend, :der_key)
        name = User.fetch(friend, :name)
        msg = 'c#{c_seq} friend\n#{name} #{der_key}\n'
        Kernel.send(conn, {:send, msg})
      end

      {:noreply, state}
    end

  end

  def handle_cast({:add, sender}, state) do
    %State{receiver: receiver, c_seq: c_seq} = state

    if c_seq == -1 do
      :timer.sleep(1000)
      User.Friends.add(self(), sender)
      {:noreply, state}
    else
      der_key = User.fetch(sender, :der_key)
      name = User.fetch(sender, :name)
      conn = User.fetch(receiver, :conn)
      msg = 'c#{c_seq} friend\n#{name} #{der_key}\n'
      Kernel.send(conn, {:send, msg})
      state = %{state | friends: [sender] ++ state.friends}
      {:noreply, state}
    end
  end

  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end
end
