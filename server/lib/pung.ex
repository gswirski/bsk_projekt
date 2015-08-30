defmodule Pung do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    port = 24948
    server_opts = [
      certfile: "server.crt",
      keyfile: "server.key",
      reuseaddr: true,
      versions: [:"tlsv1.2"],
      active: false
    ]

    children = [
      supervisor(Task.Supervisor, [[name: Pung.TaskSupervisor]]),
      worker(Task, [Server, :accept, [port, server_opts]])
    ]

    opts = [strategy: :one_for_one, name: Pung.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
