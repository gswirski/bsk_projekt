defmodule User do
  defmodule State do
    defstruct name: "",
              der_key: "",
              public_key: nil,
              conn: nil,
              friend_requests_handler: nil,
              friends_handler: nil,
              messages_handler: nil,
              handlers: HashDict.new
  end

  use GenServer

  def start_link(conn) do
    {:ok, friend_requests} = User.FriendRequests.start_link
    {:ok, friends} = User.Friends.start_link
    {:ok, messages} = User.Messages.start_link
    {:ok, user} = GenServer.start_link(
      __MODULE__,
      %State{
        conn: conn,
        friend_requests_handler: friend_requests,
        friends_handler: friends,
        messages_handler: messages
      },
      []
    )
    User.Handler.put(friend_requests, :receiver, user)
    User.Handler.put(friends, :receiver, user)
    User.Handler.put(messages, :receiver, user)
    {:ok, user}
  end

  def send_friend_request(receiver, sender) do
    friend_requests = fetch(receiver, :friend_requests_handler)
    User.FriendRequests.send(friend_requests, sender)
  end

  def add_friend(receiver, sender) do
    friends = fetch(receiver, :friends_handler)
    User.Friends.add(friends, sender)
  end

  def send_message(receiver, sender, content) do
    messages = fetch(receiver, :messages_handler)
    User.Messages.send(messages, sender, content)
  end

  def add_handler(user, s_seq, handler) do
    s_seq = to_string(s_seq)
    IO.puts "register handler for"
    IO.inspect(s_seq)
    handlers = fetch(user, :handlers)
    put(user, :handlers, HashDict.put(handlers, s_seq, handler))
    IO.inspect(fetch(user, :handlers))
  end

  def fetch_handler(user, s_seq) do
    handlers = fetch(user, :handlers)
    IO.puts "find handler for"
    IO.inspect(s_seq)
    IO.inspect(handlers)
    {:ok, handler} = HashDict.fetch(handlers, s_seq)
    handler
  end

  def fetch(user, field) do
    GenServer.call(user, {:fetch, field})
  end

  def put(user, field, value) do
    GenServer.call(user, {:put, field, value})
  end

  def handle_call({:fetch, key}, _from, state) do
    {:ok, value} = Map.fetch(state, key)
    {:reply, value, state}
  end

  def handle_call({:put, key, value}, _from, state) do
    {:reply, :ok, Map.put(state, key, value)}
  end
end
