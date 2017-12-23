defmodule Howlong.Supervisor do
  use Supervisor

  def start_link do
    IO.puts "Starting Howlong Supervisor"
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    processes = [
      supervisor(Howlong.Database, ["./persist/"]),
      supervisor(Howlong.ServerSupervisor, []),
      worker(Howlong.Cache, [])]

    supervise(processes, strategy: :one_for_one)
  end
end