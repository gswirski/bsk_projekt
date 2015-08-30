defmodule Client do
  def connect(port) do
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', port, opts)
    IO.puts("Connected to a server on port #{port}")
    talk(socket)
  end

  defp talk(socket) do
    IO.gets('Enter msg: ')
    |> write_line(socket)

    read_line(socket)
    |> IO.puts()

    talk(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
