defmodule LexerTest do
  use ExUnit.Case
  doctest Monkeylang.Lexer

  test "greets the potato" do
    assert Monkeylang.Lexer.hello() == :potato
  end
end
