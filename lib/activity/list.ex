defmodule Activity.List do
  defstruct auto_id: 1, activities: Map.new

  def new(activities \\ []) do
    Enum.reduce(
      activities,
      %Activity.List{},
      &add_activity(&2, &1)
    )
  end

  def size(activity_list) do
    Map.size(activity_list.activities)
  end

  def add_activity(
    %Activity.List{activities: activities, auto_id: auto_id} = activity_list,
    activity
  ) do
    activity = Map.put(activity, :id, auto_id)
    new_activities = Map.put(activities, auto_id, activity)

    %Activity.List{activity_list |
      activities: new_activities,
      auto_id: auto_id + 1
    }
  end

  def activities(%Activity.List{activities: activities}) do
    activities
      |> Enum.map(fn({_, activity}) -> activity end)
  end

  def refresh_activity(activity_list, activity_id) do
    update_activity(activity_list, activity_id, fn(activity) -> %{activity| since: Date.utc_today()}  end)
  end

  def howlong(%Activity.List{activities: activities}, activity_id) do
    case activities[activity_id] do
      nil -> 
        nil
      activity ->
        activity.since
    end
  end

  def update_activity(
    %Activity.List{activities: activities} = activity_list,
    activity_id,
    updater_fun
  ) do
    case activities[activity_id] do
      nil -> 
        activity_list

      old_activity ->
        new_activity = updater_fun.(old_activity)
        new_activities = Map.put(activities, new_activity.id, new_activity)
        %Activity.List{activity_list | activities: new_activities}
    end
  end


  def delete_activity(
    %Activity.List{activities: activities} = activity_list,
    activity_id
  ) do
    %Activity.List{activity_list | activities: Map.delete(activities, activity_id)}
  end
end