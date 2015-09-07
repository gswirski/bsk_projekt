defmodule User.FriendRequests do
  defmodule Request do
    use GenServer

    def start_link(sender, receiver) do
      GenServer.start_link(__MODULE__, {sender, receiver}, [])
    end

    def handle_cast(:accept, {sender, receiver}) do
      IO.puts "accept friend request"
      User.add_friend(sender, receiver)
      User.add_friend(receiver, sender)
      {:stop, :normal, {sender, receiver}}
    end

    def handle_cast(:reject, {sender, receiver}) do
      {:stop, :normal, {sender, receiver}}
    end
  end

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %User.HandlerState{}, [])
  end

  def send(friend_requests, sender) do
    GenServer.cast(friend_requests, {:send, sender})
  end

  def handle_cast({:send, sender}, state) do
    %User.HandlerState{sender: nil, receiver: receiver, c_seq: c_seq} = state

    if c_seq == -1 do
      :timer.sleep(1000)
      User.FriendRequests.send(self(), sender)
      {:noreply, state}
    else
      name = User.fetch(sender, :name)
      conn = User.fetch(receiver, :conn)
      msg = 'c#{c_seq} friend_request\n#{name}\n'
      {:ok, friend_request} = Request.start_link(sender, receiver)
      Kernel.send(conn, {:send_and_handle, msg, friend_request})
      {:noreply, %{state | sender: sender}}
    end
  end

  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end
end
