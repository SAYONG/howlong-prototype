defmodule Howlong.Server do
  use GenServer

  # API
  def start(server_name) do
    GenServer.start(__MODULE__, server_name)
  end

  def add_activity(howlong_server, activity_name) do
    new_activity = %{name: activity_name, since: Date.utc_today()}
    GenServer.cast(howlong_server, {:add_activity, new_activity})
  end

  def activities(howlong_server) do
    GenServer.call(howlong_server, {:activities})
  end

  def howlong(howlong_server, activity_id) do
    GenServer.call(howlong_server, {:howlong, activity_id})
  end

  def refresh(howlong_server, activity_id) do
    GenServer.cast(howlong_server, {:refresh, activity_id})
  end


  # Handlers
  def init(server_name) do
    {:ok, {server_name, Howlong.Database.get(server_name) || Howlong.ActivityList.new}}
  end

  def handle_cast({:add_activity, new_activity}, {server_name, activity_list}) do
    new_state = Howlong.ActivityList.add_activity(activity_list, new_activity)
    Howlong.Database.store(server_name, new_state)
    {:noreply, {server_name, new_state}}
  end

  def handle_cast({:refresh, activity_id}, {server_name, activity_list}) do
    new_state = Howlong.ActivityList.refresh_activity(activity_list, activity_id)
    {:noreply, {server_name, new_state}}
  end

  def handle_call({:activities}, _, {server_name, activity_list}) do
    {:reply, Howlong.ActivityList.activities(activity_list), {server_name, activity_list}}
  end

  def handle_call({:howlong, activity_id}, _, {server_name, activity_list}) do
    {:reply, Howlong.ActivityList.howlong(activity_list, activity_id), {server_name, activity_list}}
  end

  # Needed for testing purposes
  def handle_info(:stop, todo_list), do: {:stop, :normal, todo_list}
  def handle_info(_, state), do: {:noreply, state}
end