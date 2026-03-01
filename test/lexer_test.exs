defmodule LexerTest do
  use ExUnit.Case
  doctest Monkeylang.Lexer

  alias Monkeylang.Lexer

  test "lexer2" do
    input = "=+(){},;"

    tokens =
      Lexer.tokenize(input)

    expected = [
      %Monkeylang.Token{type: :assign, literal: "=", precedence: 0},
      %Monkeylang.Token{type: :plus, literal: "+", precedence: 3},
      %Monkeylang.Token{type: :lparen, literal: "(", precedence: 6},
      %Monkeylang.Token{type: :rparen, literal: ")", precedence: 0},
      %Monkeylang.Token{type: :lbrace, literal: "{", precedence: 0},
      %Monkeylang.Token{type: :rbrace, literal: "}", precedence: 0},
      %Monkeylang.Token{type: :comma, literal: ",", precedence: 0},
      %Monkeylang.Token{type: :semicolon, literal: ";", precedence: 0},
      %Monkeylang.Token{type: :eof, literal: "", precedence: 0}
    ]

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

    tokens =
      Lexer.tokenize(input)

    expected = [
      %Monkeylang.Token{type: :let, literal: "let", precedence: 0},
      %Monkeylang.Token{type: :ident, literal: "five", precedence: 0},
      %Monkeylang.Token{type: :assign, literal: "=", precedence: 0},
      %Monkeylang.Token{type: :int, literal: "5", precedence: 0},
      %Monkeylang.Token{type: :semicolon, literal: ";", precedence: 0},
      %Monkeylang.Token{type: :let, literal: "let", precedence: 0},
      %Monkeylang.Token{type: :ident, literal: "ten", precedence: 0},
      %Monkeylang.Token{type: :assign, literal: "=", precedence: 0},
      %Monkeylang.Token{type: :int, literal: "10", precedence: 0},
      %Monkeylang.Token{type: :semicolon, literal: ";", precedence: 0},
      %Monkeylang.Token{type: :let, literal: "let", precedence: 0},
      %Monkeylang.Token{type: :ident, literal: "add", precedence: 0},
      %Monkeylang.Token{type: :assign, literal: "=", precedence: 0},
      %Monkeylang.Token{type: :function, literal: "fn", precedence: 0},
      %Monkeylang.Token{type: :lparen, literal: "(", precedence: 6},
      %Monkeylang.Token{type: :ident, literal: "x", precedence: 0},
      %Monkeylang.Token{type: :comma, literal: ",", precedence: 0},
      %Monkeylang.Token{type: :ident, literal: "y", precedence: 0},
      %Monkeylang.Token{type: :rparen, literal: ")", precedence: 0},
      %Monkeylang.Token{type: :lbrace, literal: "{", precedence: 0},
      %Monkeylang.Token{type: :ident, literal: "x", precedence: 0},
      %Monkeylang.Token{type: :plus, literal: "+", precedence: 3},
      %Monkeylang.Token{type: :ident, literal: "y", precedence: 0},
      %Monkeylang.Token{type: :semicolon, literal: ";", precedence: 0},
      %Monkeylang.Token{type: :rbrace, literal: "}", precedence: 0},
      %Monkeylang.Token{type: :semicolon, literal: ";", precedence: 0},
      %Monkeylang.Token{type: :let, literal: "let", precedence: 0},
      %Monkeylang.Token{type: :ident, literal: "result", precedence: 0},
      %Monkeylang.Token{type: :assign, literal: "=", precedence: 0},
      %Monkeylang.Token{type: :ident, literal: "add", precedence: 0},
      %Monkeylang.Token{type: :lparen, literal: "(", precedence: 6},
      %Monkeylang.Token{type: :ident, literal: "five", precedence: 0},
      %Monkeylang.Token{type: :comma, literal: ",", precedence: 0},
      %Monkeylang.Token{type: :ident, literal: "ten", precedence: 0},
      %Monkeylang.Token{type: :rparen, literal: ")", precedence: 0},
      %Monkeylang.Token{type: :semicolon, literal: ";", precedence: 0},
      %Monkeylang.Token{type: :eof, literal: "", precedence: 0}
    ]

    assert tokens == expected
  end

  test "equals" do
    input = """
      a == b;
    """

    tokens =
      Lexer.tokenize(input)

    expected = [
      %Monkeylang.Token{type: :ident, literal: "a", precedence: 0},
      %Monkeylang.Token{type: :equals, literal: "==", precedence: 1},
      %Monkeylang.Token{type: :ident, literal: "b", precedence: 0},
      %Monkeylang.Token{type: :semicolon, literal: ";", precedence: 0},
      %Monkeylang.Token{type: :eof, literal: "", precedence: 0}
    ]

    assert tokens == expected
  end

  test "notequals" do
    input = """
      a != b;
      !a;
    """

    expected = [
      %Monkeylang.Token{type: :ident, literal: "a", precedence: 0},
      %Monkeylang.Token{type: :notequals, literal: "!=", precedence: 1},
      %Monkeylang.Token{type: :ident, literal: "b", precedence: 0},
      %Monkeylang.Token{type: :semicolon, literal: ";", precedence: 0},
      %Monkeylang.Token{type: :bang, literal: "!", precedence: 0},
      %Monkeylang.Token{type: :ident, literal: "a", precedence: 0},
      %Monkeylang.Token{type: :semicolon, literal: ";", precedence: 0},
      %Monkeylang.Token{type: :eof, literal: "", precedence: 0}
    ]

    assert Lexer.tokenize(input) == expected
  end

  test "chapter 1.4" do
    input = """
      !-/*5;
      5 < 10 > 5;
    """

    expected = [
      %Monkeylang.Token{type: :bang, literal: "!", precedence: 0},
      %Monkeylang.Token{type: :minus, literal: "-", precedence: 3},
      %Monkeylang.Token{type: :slash, literal: "/", precedence: 4},
      %Monkeylang.Token{type: :asterisk, literal: "*", precedence: 4},
      %Monkeylang.Token{type: :int, literal: "5", precedence: 0},
      %Monkeylang.Token{type: :semicolon, literal: ";", precedence: 0},
      %Monkeylang.Token{type: :int, literal: "5", precedence: 0},
      %Monkeylang.Token{type: :lt, literal: "<", precedence: 2},
      %Monkeylang.Token{type: :int, literal: "10", precedence: 0},
      %Monkeylang.Token{type: :gt, literal: ">", precedence: 2},
      %Monkeylang.Token{type: :int, literal: "5", precedence: 0},
      %Monkeylang.Token{type: :semicolon, literal: ";", precedence: 0},
      %Monkeylang.Token{type: :eof, literal: "", precedence: 0}
    ]

    assert Lexer.tokenize(input) == expected
  end

  test "keywords" do
    input = """
      let asdf = fn(a) { a + 1 };
      if (5 < 10) {
        return true;
      } else {
        return false;
      }
    """

    expected = [
      %Monkeylang.Token{type: :let, literal: "let", precedence: 0},
      %Monkeylang.Token{type: :ident, literal: "asdf", precedence: 0},
      %Monkeylang.Token{type: :assign, literal: "=", precedence: 0},
      %Monkeylang.Token{type: :function, literal: "fn", precedence: 0},
      %Monkeylang.Token{type: :lparen, literal: "(", precedence: 6},
      %Monkeylang.Token{type: :ident, literal: "a", precedence: 0},
      %Monkeylang.Token{type: :rparen, literal: ")", precedence: 0},
      %Monkeylang.Token{type: :lbrace, literal: "{", precedence: 0},
      %Monkeylang.Token{type: :ident, literal: "a", precedence: 0},
      %Monkeylang.Token{type: :plus, literal: "+", precedence: 3},
      %Monkeylang.Token{type: :int, literal: "1", precedence: 0},
      %Monkeylang.Token{type: :rbrace, literal: "}", precedence: 0},
      %Monkeylang.Token{type: :semicolon, literal: ";", precedence: 0},
      %Monkeylang.Token{type: :if, literal: "if", precedence: 0},
      %Monkeylang.Token{type: :lparen, literal: "(", precedence: 6},
      %Monkeylang.Token{type: :int, literal: "5", precedence: 0},
      %Monkeylang.Token{type: :lt, literal: "<", precedence: 2},
      %Monkeylang.Token{type: :int, literal: "10", precedence: 0},
      %Monkeylang.Token{type: :rparen, literal: ")", precedence: 0},
      %Monkeylang.Token{type: :lbrace, literal: "{", precedence: 0},
      %Monkeylang.Token{type: :return, literal: "return", precedence: 0},
      %Monkeylang.Token{type: true, literal: "true", precedence: 0},
      %Monkeylang.Token{type: :semicolon, literal: ";", precedence: 0},
      %Monkeylang.Token{type: :rbrace, literal: "}", precedence: 0},
      %Monkeylang.Token{type: :else, literal: "else", precedence: 0},
      %Monkeylang.Token{type: :lbrace, literal: "{", precedence: 0},
      %Monkeylang.Token{type: :return, literal: "return", precedence: 0},
      %Monkeylang.Token{type: false, literal: "false", precedence: 0},
      %Monkeylang.Token{type: :semicolon, literal: ";", precedence: 0},
      %Monkeylang.Token{type: :rbrace, literal: "}", precedence: 0},
      %Monkeylang.Token{type: :eof, literal: "", precedence: 0}
    ]

    assert Lexer.tokenize(input) == expected
  end

  test "single line input" do
    Lexer.tokenize("1 + 1")
    Lexer.tokenize("a + b")
  end

  test "strings" do
    input = """
      a = "hello world"
    """

    expected = [
      %Monkeylang.Token{literal: "a", precedence: 0, type: :ident},
      %Monkeylang.Token{literal: "=", precedence: 0, type: :assign},
      %Monkeylang.Token{literal: "hello world", precedence: 0, type: :string},
      %Monkeylang.Token{literal: "", precedence: 0, type: :eof}
    ]

    assert Lexer.tokenize(input) == expected

    input = """
      a = "hello \\" world"
    """

    expected = [
      %Monkeylang.Token{literal: "a", precedence: 0, type: :ident},
      %Monkeylang.Token{literal: "=", precedence: 0, type: :assign},
      %Monkeylang.Token{literal: "hello \" world", precedence: 0, type: :string},
      %Monkeylang.Token{literal: "", precedence: 0, type: :eof}
    ]

    assert Lexer.tokenize(input) == expected

    input = """
      a = "hello \\\\ world"
    """

    expected = [
      %Monkeylang.Token{literal: "a", precedence: 0, type: :ident},
      %Monkeylang.Token{literal: "=", precedence: 0, type: :assign},
      %Monkeylang.Token{literal: "hello \\ world", precedence: 0, type: :string},
      %Monkeylang.Token{literal: "", precedence: 0, type: :eof}
    ]

    assert Lexer.tokenize(input) == expected
  end

  test "arrays" do
    input = """
      ["hello", "world", 1]
    """

    expected = [
      %Monkeylang.Token{literal: "[", precedence: 7, type: :lbracket},
      %Monkeylang.Token{literal: "hello", precedence: 0, type: :string},
      %Monkeylang.Token{literal: ",", precedence: 0, type: :comma},
      %Monkeylang.Token{literal: "world", precedence: 0, type: :string},
      %Monkeylang.Token{literal: ",", precedence: 0, type: :comma},
      %Monkeylang.Token{literal: "1", precedence: 0, type: :int},
      %Monkeylang.Token{literal: "]", precedence: 0, type: :rbracket},
      %Monkeylang.Token{literal: "", precedence: 0, type: :eof}
    ]

    assert Lexer.tokenize(input) == expected
  end
end
