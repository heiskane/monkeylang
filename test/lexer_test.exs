defmodule LexerTest do
  use ExUnit.Case
  doctest Monkeylang.Lexer

  alias Monkeylang.Lexer

  test "test read_char" do
    lexer = Lexer.new("+")
    |> Monkeylang.Lexer.read_char()

    dbg(lexer)

    assert lexer.ch == "+"
    assert lexer.readPosition == 1
    assert lexer.position == lexer.readPosition
  end

  test "test next_token" do
    { lexer, token } = Lexer.new("+")
    |> Monkeylang.Lexer.read_char()
    |> Monkeylang.Lexer.next_token()

    dbg(token)
    
    assert token == %Monkeylang.Token{ type: :plus, literal: "+" }
  end
end
