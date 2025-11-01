defmodule LexerTest do
  use ExUnit.Case
  doctest Monkeylang.Lexer

  alias Monkeylang.LexerOld
  alias Monkeylang.Lexer

  test "test next_token" do
    input = "=+(){},;"

    lexer = LexerOld.new(input)

    expected = [
      %Monkeylang.Token{type: :assign, literal: "="},
      %Monkeylang.Token{type: :plus, literal: "+"},
      %Monkeylang.Token{type: :lparen, literal: "("},
      %Monkeylang.Token{type: :rparen, literal: ")"},
      %Monkeylang.Token{type: :lbrace, literal: "{"},
      %Monkeylang.Token{type: :rbrace, literal: "}"},
      %Monkeylang.Token{type: :comma, literal: ","},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :eof, literal: ""}
    ]

    Enum.reduce_while(expected, lexer, fn t, lexer ->
      {lexer, token} = LexerOld.next_token(lexer)
      assert token == t

      case token.type do
        :eof -> {:halt, lexer}
        _ -> {:cont, lexer}
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
      LexerOld.new(input)
      |> LexerOld.tokenize()

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

  test "test lexer2" do
    input = "=+(){},;"

    expected = [
      %Monkeylang.Token{type: :assign, literal: "="},
      %Monkeylang.Token{type: :plus, literal: "+"},
      %Monkeylang.Token{type: :lparen, literal: "("},
      %Monkeylang.Token{type: :rparen, literal: ")"},
      %Monkeylang.Token{type: :lbrace, literal: "{"},
      %Monkeylang.Token{type: :rbrace, literal: "}"},
      %Monkeylang.Token{type: :comma, literal: ","},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :eof, literal: ""}
    ]

    tokens = Lexer.tokenize(input)
    # |> dbg()

    assert tokens == expected
  end

  test "parse code block lexer2" do
    input = """
      let five = 5;
      let ten = 10;

      let add = fn(x, y) {
        x + y;
      };

      let result = add(five, ten);
    """

    expected = [
      %Monkeylang.Token{type: :let, literal: "let"},
      %Monkeylang.Token{type: :ident, literal: "five"},
      %Monkeylang.Token{type: :assign, literal: "="},
      %Monkeylang.Token{type: :int, literal: "5"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :let, literal: "let"},
      %Monkeylang.Token{type: :ident, literal: "ten"},
      %Monkeylang.Token{type: :assign, literal: "="},
      %Monkeylang.Token{type: :int, literal: "10"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :let, literal: "let"},
      %Monkeylang.Token{type: :ident, literal: "add"},
      %Monkeylang.Token{type: :assign, literal: "="},
      %Monkeylang.Token{type: :function, literal: "fn"},
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
      %Monkeylang.Token{type: :let, literal: "let"},
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

    tokens = Lexer.tokenize(input)

    assert tokens == expected
  end

  test "test equals" do
    input = """
      a == b;
    """

    tokens = Lexer.tokenize(input)

    expected = [
      %Monkeylang.Token{type: :ident, literal: "a"},
      %Monkeylang.Token{type: :equals, literal: "=="},
      %Monkeylang.Token{type: :ident, literal: "b"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :eof, literal: ""}
    ]

    assert tokens == expected
  end

  test "test unequals" do
    input = """
      a != b;
      !a;
    """

    expected = [
      %Monkeylang.Token{type: :ident, literal: "a"},
      %Monkeylang.Token{type: :unequals, literal: "!="},
      %Monkeylang.Token{type: :ident, literal: "b"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :bang, literal: "!"},
      %Monkeylang.Token{type: :ident, literal: "a"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :eof, literal: ""}
    ]

    assert Lexer.tokenize(input) == expected
  end

  test "test chapter 1.4" do
    input = """
      !-/*5;
      5 < 10 > 5;
    """

    expected = [
      %Monkeylang.Token{type: :bang, literal: "!"},
      %Monkeylang.Token{type: :minus, literal: "-"},
      %Monkeylang.Token{type: :slash, literal: "/"},
      %Monkeylang.Token{type: :asterisk, literal: "*"},
      %Monkeylang.Token{type: :int, literal: "5"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :int, literal: "5"},
      %Monkeylang.Token{type: :lt, literal: "<"},
      %Monkeylang.Token{type: :int, literal: "10"},
      %Monkeylang.Token{type: :gt, literal: ">"},
      %Monkeylang.Token{type: :int, literal: "5"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :eof, literal: ""}
    ]

    assert Lexer.tokenize(input) == expected
  end
end
