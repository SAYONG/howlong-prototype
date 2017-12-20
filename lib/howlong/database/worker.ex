defmodule Howlong.Database.Worker do
  use GenServer

  # API
  def start_link(db_folder, worker_id) do
    IO.puts "Starting Database Worker #{worker_id}"
    GenServer.start_link(__MODULE__, db_folder, name: via_tuple(worker_id))
  end

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  # Handlers

  def init(db_folder) do
    File.mkdir_p(db_folder)
    {:ok, db_folder}
  end

  def handle_cast({:store, key, data}, db_folder) do
    file_name(db_folder, key)
      |> File.write!(:erlang.term_to_binary(data))

      {:noreply, db_folder}
  end

  def handle_call({:get, key}, _, db_folder) do
    data = case File.read(file_name(db_folder, key)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end

    {:reply, data, db_folder}
  end

  defp file_name(db_folder, key) do
    "#{db_folder}/#{key}"
  end

  defp via_tuple(worker_id) do
    {:via, Howlong.ProcessRegistry, {:database_worker, worker_id}}
  end
end