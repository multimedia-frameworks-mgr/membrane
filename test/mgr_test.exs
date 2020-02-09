defmodule MgrTest do
  use ExUnit.Case
  doctest Mgr

  test "greets the world" do
    assert Mgr.hello() == :world
  end
end
