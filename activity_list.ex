defmodule ActivityList do
  def new do
    Map.new
  end

  def add_activity(act_list, act) do
    now = DateTime.utc_now
    Map.put(act_list, act, now)
  end

  def refresh(act_list, act) do
    Map.update!(act_list, act, &DateTime.utc_now/0)
  end

  def get_howlong(act_list, act) do
    last = Map.get(act_list, act)
    DateTime.utc_now |> DateTime.diff(last)
  end
end