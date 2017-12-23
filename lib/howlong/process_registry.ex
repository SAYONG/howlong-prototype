defmodule Howlong.ProcessRegistry do
  import Kernel, except: [send: 2]

  use GenServer

  #API
  def start_link do
    IO.puts "Starting ProcessRegistry Service"
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def register_name(key, pid) do
    GenServer.call(:process_registry, {:register_name, key, pid})
  end

  def whereis_name(key) do
    case :ets.lookup(:process_registry, key) do
      [{^key, pid}] -> pid
      _ -> :undefined
    end
  end

  def unregister_name(key) do
    GenServer.cast(:process_registry, {:unregister_name, key})
  end

  def send(key, message) do
    case whereis_name(key) do
      :undefined -> {:badarg, {key, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  # Handlers
  def init(_) do
    :ets.new(:process_registry, [:named_table])
    {:ok, nil}
  end

  def handle_call({:register_name, key, pid}, _, state) do
    case :ets.insert_new(:process_registry, {key, pid}) do
      true ->
        Process.monitor(pid)
        {:reply, :yes, state}
      _ ->
        {:reply, :no, state}
    end
  end

  def handle_call({:unregister_name, key}, _, state) do
    :ets.delete(:process_registry, key)
    {:reply, key, state}
  end

  def handle_info({:DOWN, _, :process,  pid, _}, state) do
    :ets.match_delete(:process_registry, {:_, pid})
    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}

end