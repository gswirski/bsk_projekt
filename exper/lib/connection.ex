defmodule Connection do
  use GenServer

  def start_link(client) do
    GenServer.start_link(__MODULE__, client, [])
    IO.puts("connected")
  end


  def handle_cast(msg, _client) do
    IO.inspect(msg)
  end

  def handle_info(msg, _client) do
    IO.inspect(msg)
  end
end
