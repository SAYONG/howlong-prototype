defmodule Howlong.Cache do
  use GenServer

  # API
  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, server_name) do
    GenServer.call(cache_pid, {:server_process, server_name})
  end 


  # Handlers
  def init(_) do
    Howlong.Database.Server.start("./persist/")
    {:ok, Map.new}
  end

  def handle_call({:server_process, howlong_server_name}, _, howlong_servers) do
    case Map.fetch(howlong_servers, howlong_server_name) do
      {:ok, howlong_server} ->
        {:reply, howlong_server, howlong_servers}
      :error ->
        {:ok, new_howlong_server} = Howlong.Server.start(howlong_server_name)
        {:reply, new_howlong_server, Map.put(howlong_servers, howlong_server_name, new_howlong_server)}
    end
  end
end