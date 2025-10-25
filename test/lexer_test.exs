defmodule LexerTest do
  use ExUnit.Case
  doctest Monkeylang.Lexer

  alias Monkeylang.Lexer

  test "test next_token" do
    input = "=+(){},;"

    lexer = Lexer.new(input)

    expected = [
      %Monkeylang.Token{type: :assign, literal: "="},
      %Monkeylang.Token{type: :plus, literal: "+"},
      %Monkeylang.Token{type: :lparen, literal: "("},
      %Monkeylang.Token{type: :rparen, literal: ")"},
      %Monkeylang.Token{type: :lbrace, literal: "{"},
      %Monkeylang.Token{type: :rbrace, literal: "}"},
      %Monkeylang.Token{type: :comma, literal: ","},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :eof, literal: ""},
    ]

    # Lexer.tokenize(lexer)
    # |> dbg()

    Enum.reduce_while(expected, lexer, fn t, lexer ->
      # dbg({ t, lexer })
      { lexer, token } = Lexer.next_token(lexer)
      assert token == t

      case token.type do
        :eof -> { :halt, lexer }
        _ -> { :cont, lexer }
      end
    end)
  end

  test "parse code block" do
    input = """
      let five = 5;
      let ten = 10;

      let add = fn(x, y) {
        x + y;
      };

      let result = add(five, ten);
    """

    tokens =
      Lexer.new(input)
      |> Lexer.tokenize()

    expected = [
      %Monkeylang.Token{type: :ident, literal: "let"},
      %Monkeylang.Token{type: :ident, literal: "five"},
      %Monkeylang.Token{type: :assign, literal: "="},
      %Monkeylang.Token{type: :int, literal: "5"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :ident, literal: "let"},
      %Monkeylang.Token{type: :ident, literal: "ten"},
      %Monkeylang.Token{type: :assign, literal: "="},
      %Monkeylang.Token{type: :int, literal: "10"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :ident, literal: "let"},
      %Monkeylang.Token{type: :ident, literal: "add"},
      %Monkeylang.Token{type: :assign, literal: "="},
      %Monkeylang.Token{type: :ident, literal: "fn"},
      %Monkeylang.Token{type: :lparen, literal: "("},
      %Monkeylang.Token{type: :ident, literal: "x"},
      %Monkeylang.Token{type: :comma, literal: ","},
      %Monkeylang.Token{type: :ident, literal: "y"},
      %Monkeylang.Token{type: :rparen, literal: ")"},
      %Monkeylang.Token{type: :lbrace, literal: "{"},
      %Monkeylang.Token{type: :ident, literal: "x"},
      %Monkeylang.Token{type: :plus, literal: "+"},
      %Monkeylang.Token{type: :ident, literal: "y"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :rbrace, literal: "}"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :ident, literal: "let"},
      %Monkeylang.Token{type: :ident, literal: "result"},
      %Monkeylang.Token{type: :assign, literal: "="},
      %Monkeylang.Token{type: :ident, literal: "add"},
      %Monkeylang.Token{type: :lparen, literal: "("},
      %Monkeylang.Token{type: :ident, literal: "five"},
      %Monkeylang.Token{type: :comma, literal: ","},
      %Monkeylang.Token{type: :ident, literal: "ten"},
      %Monkeylang.Token{type: :rparen, literal: ")"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :eof, literal: ""}
    ]

    assert tokens == expected
  end
end
