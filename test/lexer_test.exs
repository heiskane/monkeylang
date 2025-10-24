defmodule LexerTest do
  use ExUnit.Case
  doctest Monkeylang.Lexer

  alias Monkeylang.Lexer

  # test "test read_char" do
  #   lexer =
  #     Lexer.new("+")
  #     |> Monkeylang.Lexer.read_char()
  #
  #   dbg(lexer)
  #
  #   assert lexer.ch == "+"
  #   assert lexer.readPosition == 1
  #   assert lexer.position == lexer.readPosition
  # end
  #
  # test "test next_token" do
  #   {_lexer, token} =
  #     Lexer.new("+")
  #     |> Monkeylang.Lexer.next_token()
  #
  #   dbg(token)
  #
  #   assert token == %Monkeylang.Token{type: :plus, literal: "+"}
  # end

  test "parse code block" do
    input = """
      let five = 5;
      let ten = 10;

      let add = fn(x, y) {
        x + y;
      };

      let result = add(five, ten);
    """

    lexer = Lexer.new(input)

    Enum.reduce(1..2, lexer, fn _, lexer ->
      { lexer, token } = lexer
      |> Lexer.next_token()
      |> dbg()

      lexer
    end)
  end
end
