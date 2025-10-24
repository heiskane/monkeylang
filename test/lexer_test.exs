defmodule LexerTest do
  use ExUnit.Case
  doctest Monkeylang.Lexer

  alias Monkeylang.Lexer

  test "test read_char" do
    { lexer, char } = Lexer.new("+")
    |> Monkeylang.Lexer.read_char()

    assert char == "+"
    assert lexer.readPosition == 1
    assert lexer.position == lexer.readPosition
  end
end
