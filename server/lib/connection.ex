defmodule Connection do
  defmodule State do
    defstruct socket: nil, seq: 0, buff: "", users: nil, current_user: nil
  end

  def start(state) do
    {:ok, user} = User.start_link(self())
    serve(%{state | current_user: user})
  end

  def serve(state) do
    receive do
      {:ssl, _, msg} -> serve(Connection.recv(msg, state))
      {:send, msg} -> serve(Connection.send(msg, state))
      {:send_and_handle, msg, handler} -> serve(Connection.send_and_handle(msg, handler, state))
    end
  end

  def send_and_handle(msg, handler, state) do
    IO.puts "registered handler for #{state.seq}"
    User.add_handler(state.current_user, state.seq, handler)
    Connection.send(msg, state)
  end

  def send(msg, state) do
    IO.puts("SEND")
    IO.inspect(msg)
    seq = state.seq
    :ssl.send(state.socket, 's#{seq} #{msg}')
    %{state | seq: seq + 1}
  end

  def recv(msg, state) do
    IO.puts("RECV")
    IO.puts(msg)
    state = %{state | buff: state.buff <> to_string(msg)}
    if length(String.split(state.buff, "\n")) > 2 do
      request = Parser.parse(state.buff)
      state = %{state | buff: ""}
      handle(request, state)
    else
      state
    end
  end

  def handle(%Request{cmd: "signup", c: c, payload: payload}, state) do
    [login, b64_der] = String.split(payload, " ", parts: 2, trim: true)
    b64_key = "-----BEGIN PUBLIC KEY-----\n#{b64_der}\n-----END PUBLIC KEY-----"
    entries = :public_key.pem_decode(b64_key)
    entry = hd(entries)
    key = :public_key.pem_entry_decode(entry)
    User.put(state.current_user, :name, "#{login}@localhost")
    User.put(state.current_user, :der_key, b64_der)
    User.put(state.current_user, :public_key, key)
    secret = "dupa"
    payload = :public_key.encrypt_public(secret, key)
    payload = :base64.encode(payload)
    data = 'c#{c} decrypt\n#{payload}\n'
    Kernel.send(self(), {:send, data})
    state
  end

  def handle(%Request{cmd: "check", c: c, payload: payload}, state) do
    IO.inspect(payload)
    :ok = User.Registry.sign_up(state.users, state.current_user)
    data = 'c#{c} ok\n\n'
    Kernel.send(self(), {:send, data})
    state
  end

  def handle(%Request{cmd: "add_friend", c: c, payload: payload}, state) do
    friend = payload
    {:ok, receiver} = User.Registry.lookup(state.users, friend)
    User.send_friend_request(receiver, state.current_user)
    data = 'c#{c} ok\n\n'
    Kernel.send(self(), {:send, data})
    state
  end

  def handle(%Request{cmd: "send_message", c: c, payload: payload}, state) do
    [receiver_name, content] = String.split(payload, " ", parts: 2, trim: true)
    {:ok, receiver} = User.Registry.lookup(state.users, receiver_name)
    User.send_message(receiver, state.current_user, content)
    data = 'c#{c} ok\n\n'
    Kernel.send(self(), {:send, data})
    state
  end

  def handle(%Request{cmd: "get_friend_requests", c: c}, state) do
    friend_requests = User.fetch(state.current_user, :friend_requests_handler)
    User.Handler.put(friend_requests, :c_seq, c)
    state
  end

  def handle(%Request{cmd: "get_friends", c: c}, state) do
    friends = User.fetch(state.current_user, :friends_handler)
    User.Handler.put(friends, :c_seq, c)
    state
  end

  def handle(%Request{cmd: "get_messages", c: c}, state) do
    messages = User.fetch(state.current_user, :messages_handler)
    User.Handler.put(messages, :c_seq, c)
    state
  end

  def handle(%Request{cmd: "accept", s: s}, state) do
    IO.puts "accept attempt"
    handler = User.fetch_handler(state.current_user, s)
    GenServer.cast(handler, :accept)
    state
  end

  def handle(_, state) do
    IO.puts("noop")
    state
  end
end
