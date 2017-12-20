defmodule Howlong.Database do
  @pool_size 10

  # API
  def start_link(db_folder) do
    IO.puts "Starting Database server"
    Howlong.PoolSupervisor.start_link(db_folder, @pool_size)
  end

  def store(key, data) do
    key
      |> choose_worker
      |> Howlong.Database.Worker.store(key, data)
  end

  def get(key) do
    key
      |> choose_worker
      |> Howlong.Database.Worker.get(key)
  end

  # Private
  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end