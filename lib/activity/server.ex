defmodule Activity.Server do
  use GenServer

  # API
  def start do
    GenServer.start(Activity.Server, nil)
  end

  def add_activity(activity_server, new_activity) do
    GenServer.cast(activity_server, {:add_activity, new_activity})
  end

  def activities(activity_server) do
    GenServer.call(activity_server, {:activities, date})
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


  def handle_cast({:add_entry, new_entry}, todo_list) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    {:noreply, new_state}
  end


  def handle_call({:entries, date}, _, todo_list) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      todo_list
    }
  end

  # Needed for testing purposes
  def handle_info(:stop, todo_list), do: {:stop, :normal, todo_list}
  def handle_info(_, state), do: {:noreply, state}
end