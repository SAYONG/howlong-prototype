defmodule Howlong.ProcessRegistry do
  use GenServer

  def start_link do
    IO.puts "Starting ProcessRegistry Service"
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def register_name(key, pid) do
    nil
  end

  def unregister_name(key) do
    nil
  end

  def send(key, msg) do
    nil
  end

  def whereis_name(key) do
    nil
  end

  # Handler
  def init(_) do
    {:ok, Map.new}
  end

  def handle_call({:register_name, key, pid}, _, process_registry) do
    case Map.get(process_registry, key) do
      nil ->
        Process.monitor(pid)
        {:reply, :yes, Map.put(process_registry, key, pid)}
      _ ->
        {:reply, :no, process_registry}
    end
  end

  def handle_call({:unregister_name, key}, _, process_registry) do
    case Map.get(process_registry, key) do
      nil ->
        {:reply, :no, process_registry}
      pid ->
        Process.demonitor(pid)
        {:reply, :yes, Map.delete(process_registry, key)}
    end
  end

  def handle_call({:where_is_name, key}, _, process_registry) do
    {:reply, Map.get(process_registry, key, :undefined), process_registry}
  end
end