defmodule HowlongTest do
  use ExUnit.Case
  doctest Howlong

  test "greets the world" do
    assert Howlong.hello() == :world
  end
end
