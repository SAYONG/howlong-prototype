defmodule Howlong.Cache do
  use GenServer

  # API
  def start_link do
    IO.puts "Starting Howlong Cache Process"
    GenServer.start_link(__MODULE__, nil, name: :howlong_cache)
  end

  def server_process(server_name) do
    GenServer.call(:howlong_cache, {:server_process, server_name})
  end 

  # Handlers
  def init(_) do
    Howlong.Database.Server.start_link("./persist/")
    {:ok, Map.new}
  end

  def handle_call({:server_process, howlong_server_name}, _, howlong_servers) do
    case Map.fetch(howlong_servers, howlong_server_name) do
      {:ok, howlong_server} ->
        {:reply, howlong_server, howlong_servers}
      :error ->
        {:ok, new_howlong_server} = Howlong.Server.start_link(howlong_server_name)
        {:reply, new_howlong_server, Map.put(howlong_servers, howlong_server_name, new_howlong_server)}
    end
  end
end