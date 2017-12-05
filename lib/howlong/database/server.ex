defmodule Howlong.Database.Server do
  use GenServer

  # API
  def start(db_folder) do
    IO.puts "Starting Database server"
    GenServer.start(__MODULE__, db_folder,
      name: :database_server)
  end

  def store(key, data) do
    GenServer.cast(:database_server, {:store, key, data})
  end

  def get(key) do
    GenServer.call(:database_server, {:get, key})
  end

  # Handlers

  def init(db_folder) do
    worker_list = Stream.map(0..9, fn(n) -> worker_index(db_folder, n) end)
      |> Enum.map(fn(n) -> File.mkdir_p(n); n end)
      |> Enum.map(fn(n) -> {:ok, pid} = Howlong.Database.Worker.start(n); pid end)
    {:ok, worker_list}
  end

  def handle_cast({:store, key, data}, worker_list) do
    Enum.at(worker_list, get_worker(key))
      |> Howlong.Database.Worker.store(key, data)
    {:noreply, worker_list}
  end

  def handle_call({:get, key}, _, worker_list) do
    data = Enum.at(worker_list, get_worker(key))
      |> Howlong.Database.Worker.get(key)
    {:reply, data, worker_list}
  end

  defp worker_index(db_folder, index) do
    "#{db_folder}/db-#{index}"
  end

  defp get_worker(key) do
    :erlang.phash2(key, 10)
  end
end