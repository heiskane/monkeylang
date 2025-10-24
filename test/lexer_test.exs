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

    {_, tokens} =
      Enum.reduce_while(1..100, {lexer, []}, fn _, {lexer, tokens} ->
        {lexer, token} =
          lexer
          |> Lexer.next_token()

        case token.type do
          :eof -> {:halt, {lexer, tokens}}
          _ -> {:cont, {lexer, [token | tokens]}}
        end
      end)

    dbg(Enum.reverse(tokens))

    expected = [
      %Monkeylang.Token{type: :ident, literal: "let"},
      %Monkeylang.Token{type: :ident, literal: "five"},
      %Monkeylang.Token{type: :assign, literal: "="},
      %Monkeylang.Token{type: :illegal, literal: "5"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :ident, literal: "let"},
      %Monkeylang.Token{type: :ident, literal: "ten"},
      %Monkeylang.Token{type: :assign, literal: "="},
      %Monkeylang.Token{type: :illegal, literal: "1"},
      %Monkeylang.Token{type: :illegal, literal: "0"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :ident, literal: "let"},
      %Monkeylang.Token{type: :ident, literal: "add"},
      %Monkeylang.Token{type: :assign, literal: "="},
      %Monkeylang.Token{type: :ident, literal: "fn"},
      %Monkeylang.Token{type: :ident, literal: "x"},
      %Monkeylang.Token{type: :ident, literal: "y"},
      %Monkeylang.Token{type: :lbrace, literal: "{"},
      %Monkeylang.Token{type: :ident, literal: "x"},
      %Monkeylang.Token{type: :plus, literal: "+"},
      %Monkeylang.Token{type: :ident, literal: "y"},
      %Monkeylang.Token{type: :rbrace, literal: "}"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :ident, literal: "let"},
      %Monkeylang.Token{type: :ident, literal: "result"},
      %Monkeylang.Token{type: :assign, literal: "="},
      %Monkeylang.Token{type: :ident, literal: "add"},
      %Monkeylang.Token{type: :ident, literal: "five"},
      %Monkeylang.Token{type: :ident, literal: "ten"},
      %Monkeylang.Token{type: :semicolon, literal: ";"}
    ]

    assert Enum.reverse(tokens) == expected
  end
end
