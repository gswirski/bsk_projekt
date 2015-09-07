defmodule Listener do
  use GenServer

  def start_link(port, opts) do
    GenServer.start_link(__MODULE__, {port, opts}, [])
  end

  def init({port, opts}) do
    IO.puts "server start"
    listen
    {:ok, {port, opts}}
  end

  def listen do
    GenServer.cast(self(), :listen)
  end

  def accept(socket) do
    GenServer.cast(self(), {:accept, socket})
  end

  def handle_cast({:accept, socket}, conf) do
    {:ok, client} = :ssl.transport_accept(socket)
    :ok = :ssl.ssl_accept(client)
    {:ok, pid} = Connection.start_link(client)
    :ok = :ssl.controlling_process(client, pid)
    Listener.accept(socket)
    {:noreply, conf}
  end

  def handle_cast(:listen, conf) do
    {port, opts} = conf
    :ssl.start()
    {:ok, socket} = :ssl.listen(port, opts)
    IO.puts "Accepting connections on port #{port}"
    accept(socket)
    {:noreply, conf}
  end
end
