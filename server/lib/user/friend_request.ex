defmodule User.FriendRequest do
  use GenServer

  def start_link(user) do
    GenServer.start_link(__MODULE__, {user, -1}, [])
  end

  def send(pid, other_user) do
    GenServer.cast(pid, {:send, other_user})
  end

  def set_cseq(pid, cseq) do
    GenServer.cast(pid, {:set_cseq, cseq})
  end

  def handle_cast({:set_cseq, cseq}, {user, _}) do
    IO.puts "set cseq to #{cseq}"
    {:noreply, {user, cseq}}
  end

  def handle_cast({:send, other_user}, {user, cseq}) do
    IO.puts "current cseq = #{cseq}"
    if cseq == -1 do
      IO.puts "sleeping"
      :timer.sleep(1000)
      User.FriendRequest.send(self(), other_user)
      {:noreply, {user, cseq}}
    else
      IO.puts "sending"
      request = 'c#{cseq} friend_request\n#{other_user.name}\n'
      Kernel.send(user.conn, {:send_and_handle, request, self()})
      {:noreply, {user, cseq}}
    end
  end
end
