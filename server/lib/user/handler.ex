defmodule User.Handler do
  def put(handler, key, value) do
    GenServer.cast(handler, {:put, key, value})
  end
end
