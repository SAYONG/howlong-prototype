defmodule Activity do
  defstruct activity_name: nil, latest_date: nil

  def new(activity_name, latest_date) do
    %Activity{activity_name: activity_name, latest_date: latest_date}
  end

  def refresh(activity, %Date{calendar: _, day: _, month: _, year: _} = date) do
    Map.put(activity, :latest_date, date)
  end

  def howlong(activity, %Date{calendar: _, day: _, month: _, year: _} = date) do
    Date.diff(date, activity.latest_date)
  end
end


defmodule ActivityListServer do
  use GenServer

  # Hnadler
  def init(_) do
    {:ok, %{auto_id: 1, activities: []}}
  end


  def handle_call({:activities}, _, state) do
    {:reply, state.activities, state}
  end

  def handle_cast({:add_activity, activity_name, date}, state) do
    activity = {state.auto_id, Activity.new(activity_name, date)}
    new_state = Map.put(state, :activities, [activity|state.activities])
      |> Map.put(:auto_id, state.auto_id + 1)

    {:noreply, new_state}
  end

  def handle_cast({:refresh_activity, id}, state) do
    refreshed_activity = Enum.find(state.activities, &match?({^id, _}, &1))
                          |> elem(1)
                          |> Activity.refresh(Date.utc_today)
    new_activities = [{id, refreshed_activity} | Enum.filter(state.activities, &not(match?({^id, _}, &1)))]
    {:noreply, Map.put(state, :activities, new_activities)}
  end

  # Interface
  def add_activity(pid, activity_name, date) do
    GenServer.cast(pid, {:add_activity, activity_name, date})
  end

  def activities(pid) do
    GenServer.call(pid, {:activities})
  end 
end