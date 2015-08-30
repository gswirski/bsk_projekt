defmodule Server do
  def ac() do
    port = 24948
    opts = [
      certfile: "server.crt",
      keyfile: "server.key",
      reuseaddr: true,
      versions: [:"tlsv1.2"],
      active: false
    ]
    :ssl.start()
    {:ok, socket} = :ssl.listen(port, opts)
    IO.inspect(socket)
    IO.puts "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  def st() do
    :ssl.stop()
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :ssl.transport_accept(socket)
    ok = :ssl.ssl_accept(client)
    IO.inspect(ok)
    serve(client)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    data = read_line(socket)
    write_line('s16 c1 ok\nwat\n', socket)
    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :ssl.recv(socket, 0)
    IO.inspect(data)
    data
  end

  defp write_line(line, socket) do
    :ssl.send(socket, line)
  end
end
