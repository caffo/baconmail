defmodule BaconmailTest do
  use ExUnit.Case
  doctest Baconmail

  test "greets the world" do
    assert Baconmail.hello() == :world
  end
end
