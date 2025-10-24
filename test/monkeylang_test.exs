defmodule MonkeylangTest do
  use ExUnit.Case
  doctest Monkeylang

  test "greets the world" do
    assert Monkeylang.hello() == :world
  end
end
