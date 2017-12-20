defmodule Howlong.PoolSupervisor do
  use Supervisor

  # API
  def start_link(db_folder, pool_size) do
    IO.puts "Starting Pool Supervisor with size #{pool_size}"
    Supervisor.start_link(__MODULE__, {db_folder, pool_size})
  end

  #Handlers
  def init({db_folder, pool_size}) do
    processes = for worker_id <- 1..pool_size do
      worker(
        Howlong.Database.Worker, [db_folder, worker_id],
        id: {:database_worker, worker_id})
    end

    supervise(processes, strategy: :one_for_one)
  end
end