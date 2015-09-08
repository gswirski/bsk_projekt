defmodule User.Registry do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, HashDict.new, opts)
  end

  def login(registry, user) do
    IO.puts "SIGN_UP"
    IO.inspect(user)
    GenServer.call(registry, {:login, user})
  end

  def lookup(registry, login) do
    GenServer.call(registry, {:lookup, login})
  end

  ## Server callbacks

  def handle_call({:lookup, login}, _from, users) do
    {:reply, HashDict.fetch(users, login), users}
  end

  def handle_call({:login, user}, _from, users) do
    name = User.fetch(user, :name)
    {:reply, :ok, HashDict.put(users, name, user)}
  end
end

