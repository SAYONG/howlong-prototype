defmodule ActivityList do
  defstruct auto_id: 1, activities: []

  def new, do: %ActivityList{}

  def add_activity(activity_list, activity_name, today) do
    activity = {activity_list.auto_id, Activity.new(activity_name, today)}
    Map.put(activity_list, :activities, [activity|activity_list.activities])
    |> Map.put(:auto_id, activity_list.auto_id + 1)
  end

  def activities(activity_list) do
    activity_list.activities
  end

end

defmodule Activity do
  defstruct activity_name: nil, latest_date: nil

  def new(activity_name, latest_date) do
    %Activity{activity_name: activity_name, latest_date: latest_date}
  end

  def refresh(activity, %Date{calendar: _, day: _, month: _, year: _} = today) do
    Map.put(activity, :latest_date, today)
  end

  def howlong(activity, %Date{calendar: _, day: _, month: _, year: _} = today) do
    Date.diff(today, activity.latest_date)
  end
end