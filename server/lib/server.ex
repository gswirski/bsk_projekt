defmodule Server do
  def accept(port, opts) do
    :ssl.start()
    {:ok, socket} = :ssl.listen(port, opts)
    IO.puts "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :ssl.transport_accept(socket)
    :ok = :ssl.ssl_accept(client)
    {:ok, pid} = Task.Supervisor.start_child(Pung.TaskSupervisor, fn ->
      serve(client, 1)
    end)
    :ok = :ssl.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket, res) do
    request = read_line(socket)
    case request do
      {c, s, "signup", pyld} ->
        signup_user(request, socket, res)
      {c, s, "check", pyld} ->
        check_user(request, socket, res)
      _ ->
        write_line('s16 c1 ok\nwat\n', socket)
    end
    serve(socket, res + 1)
  end

  defp signup_user(request, socket, res) do
    c = elem(request, 0)
    payload = elem(request, 3)
    [login, b64_key] = String.split(payload, " ", parts: 2, trim: true)
    entries = :public_key.pem_decode(b64_key)
    entry = hd(entries)
    key = :public_key.pem_entry_decode(entry)

    secret = "dupa"
    payload = :public_key.encrypt_public(secret, key)
    payload = :base64.encode(payload)
    data = 's#{res} c#{c} decrypt\n#{payload}\n'
    write_line(data, socket)
  end

  def check_user(request, socket, res) do
    c = elem(request, 0)
    payload = elem(request, 3)
    check = String.strip(payload)
    IO.inspect(check)
    data = 's#{res} c#{c} ok\n\n'
    write_line(data, socket)
  end

  defp read_line(socket) do
    {:ok, data} = :ssl.recv(socket, 0)
    IO.puts "RECV"
    IO.inspect(data)
    result = Parser.parse(data)
    IO.inspect(result)
    result
  end

  defp write_line(line, socket) do
    IO.puts "SEND"
    IO.inspect(line)
    :ssl.send(socket, line)
  end
end
