defmodule Acceptor do
  def accept(port, opts) do
    :ssl.start()
    {:ok, socket} = :ssl.listen(port, opts)
    IO.puts "Accepting connections on port #{port}"
    {:ok, users} = User.Registry.start_link
    loop_acceptor(socket, users)
  end

  defp loop_acceptor(socket, users) do
    {:ok, client} = :ssl.transport_accept(socket)
    :ok = :ssl.ssl_accept(client)
    {:ok, pid} = Task.Supervisor.start_child(Pung.TaskSupervisor, fn ->
      Connection.start(%Connection.State{socket: client, users: users})
    end)
    :ok = :ssl.controlling_process(client, pid)
    loop_acceptor(socket, users)
  end
end
