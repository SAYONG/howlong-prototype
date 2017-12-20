defmodule Howlong.ServerSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: :howlong_server_supervisor)
  end

  def start_child(server_name) do
    Supervisor.start_child(:howlong_server_supervisor, [server_name])
  end

  def init(_) do
    supervise(
      [worker(Howlong.Server, [])],
      strategy: :simple_one_for_one
    )
  end
end