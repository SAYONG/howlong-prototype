defmodule Activity.Server do
  use GenServer

  # API
  def start do
    GenServer.start(Activity.Server, nil)
  end

  def add_activity(activity_server, activity_name) do
    new_activity = %{name: activity_name, since: Date.utc_today()}
    GenServer.cast(activity_server, {:add_activity, new_activity})
  end

  def activities(activity_server) do
    GenServer.call(activity_server, {:activities})
  end

  def howlong(activity_server, activity_id) do
    GenServer.call(activity_server, {:howlong, activity_id})
  end

  def refresh(activity_server, activity_id) do
    GenServer.cast(activity_server, {:refresh, activity_id})
  end


  # Handlers
  def init(_) do
    {:ok, Activity.List.new}
  end

  def handle_cast({:add_activity, new_activity}, activity_list) do
    new_state = Activity.List.add_activity(activity_list, new_activity)
    {:noreply, new_state}
  end

  def handle_cast({:refresh, activity_id}, activity_list) do
    new_state = Activity.List.refresh_activity(activity_list, activity_id)
    {:noreply, new_state}
  end

  def handle_call({:activities}, _, activity_list) do
    {:reply, Activity.List.activities(activity_list), activity_list}
  end

  def handle_call({:howlong, activity_id}, _, activity_list) do
    {:reply, Activity.List.howlong(activity_list, activity_id), activity_list}
  end

  # Needed for testing purposes
  def handle_info(:stop, todo_list), do: {:stop, :normal, todo_list}
  def handle_info(_, state), do: {:noreply, state}
end