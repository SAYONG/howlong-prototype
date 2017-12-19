defmodule Howlong.ProcessRegistry do
  use GenServer

  #API
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def register_name(key, pid) do
    GenServer.call(:process_registry, {:register_name, key, pid})
  end

  def whereis_name(key) do
    GenServer.call(:process_registry, {:whereis_name, key})
  end

  def unregister_name(key) do
    GenServer.cast(:process_registry, {:unregister_name, key})
  end


  # Handlers
  def init(_) do
    {:ok, Map.new}
  end

  def handle_call({:registry_name, key, pid}, _, process_registry) do
    case Map.get(process_registry, key) do
      nil ->
        Process.monitor(pid)
        {:reply, :yes, Map.put(process_registry, key, pid)}
      _ ->
        {:reply, :no, process_registry}
    end
  end

  def handle_call({:registry_name, key} _, process_registry) do
    {:reply, Map.get(process_registry, key, :undefined), process_registry}
  end

  def handle_info({:DOWN, _, :process,  pid, _}, process_registry) do
    {:noreply, deregister_pid(process_registry, pid)}
  end

  def handle_info(_, state), do: {:noreply, state}


  # Utils
  defp deregister_pid(process_registry, pid) do
    Enum.reduce(
      process_registry,
      process_registry,
      fn 
        ({process_key, process_id}, registry_acc) when process_id == pid ->
          Map.delete(process_registry, process_key)
        (_, registry_acc) -> registry_acc
      end
    )
  end
end