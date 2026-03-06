defmodule LexerTest do
  use ExUnit.Case
  doctest Monkeylang.Lexer

  alias Monkeylang.Lexer

  test "lexer2" do
    input = "=+(){},;"

    tokens =
      Lexer.tokenize(input)

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

    assert tokens == expected
  end

  test "equals" do
    input = """
      a == b;
    """

    tokens =
      Lexer.tokenize(input)

    expected = [
      %Monkeylang.Token{type: :ident, literal: "a"},
      %Monkeylang.Token{type: :equals, literal: "=="},
      %Monkeylang.Token{type: :ident, literal: "b"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :eof, literal: ""}
    ]

    assert tokens == expected
  end

  test "notequals" do
    input = """
      a != b;
      !a;
    """

    expected = [
      %Monkeylang.Token{type: :ident, literal: "a"},
      %Monkeylang.Token{type: :notequals, literal: "!="},
      %Monkeylang.Token{type: :ident, literal: "b"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :bang, literal: "!"},
      %Monkeylang.Token{type: :ident, literal: "a"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :eof, literal: ""}
    ]

    assert Lexer.tokenize(input) == expected
  end

  test "chapter 1.4" do
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
      %Monkeylang.Token{type: :let, literal: "let"},
      %Monkeylang.Token{type: :ident, literal: "asdf"},
      %Monkeylang.Token{type: :assign, literal: "="},
      %Monkeylang.Token{type: :function, literal: "fn"},
      %Monkeylang.Token{type: :lparen, literal: "("},
      %Monkeylang.Token{type: :ident, literal: "a"},
      %Monkeylang.Token{type: :rparen, literal: ")"},
      %Monkeylang.Token{type: :lbrace, literal: "{"},
      %Monkeylang.Token{type: :ident, literal: "a"},
      %Monkeylang.Token{type: :plus, literal: "+"},
      %Monkeylang.Token{type: :int, literal: "1"},
      %Monkeylang.Token{type: :rbrace, literal: "}"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :if, literal: "if"},
      %Monkeylang.Token{type: :lparen, literal: "("},
      %Monkeylang.Token{type: :int, literal: "5"},
      %Monkeylang.Token{type: :lt, literal: "<"},
      %Monkeylang.Token{type: :int, literal: "10"},
      %Monkeylang.Token{type: :rparen, literal: ")"},
      %Monkeylang.Token{type: :lbrace, literal: "{"},
      %Monkeylang.Token{type: :return, literal: "return"},
      %Monkeylang.Token{type: true, literal: "true"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :rbrace, literal: "}"},
      %Monkeylang.Token{type: :else, literal: "else"},
      %Monkeylang.Token{type: :lbrace, literal: "{"},
      %Monkeylang.Token{type: :return, literal: "return"},
      %Monkeylang.Token{type: false, literal: "false"},
      %Monkeylang.Token{type: :semicolon, literal: ";"},
      %Monkeylang.Token{type: :rbrace, literal: "}"},
      %Monkeylang.Token{type: :eof, literal: ""}
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
      %Monkeylang.Token{literal: "a", type: :ident},
      %Monkeylang.Token{literal: "=", type: :assign},
      %Monkeylang.Token{literal: "hello world", type: :string},
      %Monkeylang.Token{literal: "", type: :eof}
    ]

    assert Lexer.tokenize(input) == expected

    input = """
      a = "hello \\" world"
    """

    expected = [
      %Monkeylang.Token{literal: "a", type: :ident},
      %Monkeylang.Token{literal: "=", type: :assign},
      %Monkeylang.Token{literal: "hello \" world", type: :string},
      %Monkeylang.Token{literal: "", type: :eof}
    ]

    assert Lexer.tokenize(input) == expected

    input = """
      a = "hello \\\\ world"
    """

    expected = [
      %Monkeylang.Token{literal: "a", type: :ident},
      %Monkeylang.Token{literal: "=", type: :assign},
      %Monkeylang.Token{literal: "hello \\ world", type: :string},
      %Monkeylang.Token{literal: "", type: :eof}
    ]

    assert Lexer.tokenize(input) == expected
  end

  test "arrays" do
    input = """
      ["hello", "world", 1]
    """

    expected = [
      %Monkeylang.Token{literal: "[", type: :lbracket},
      %Monkeylang.Token{literal: "hello", type: :string},
      %Monkeylang.Token{literal: ",", type: :comma},
      %Monkeylang.Token{literal: "world", type: :string},
      %Monkeylang.Token{literal: ",", type: :comma},
      %Monkeylang.Token{literal: "1", type: :int},
      %Monkeylang.Token{literal: "]", type: :rbracket},
      %Monkeylang.Token{literal: "", type: :eof}
    ]

    assert Lexer.tokenize(input) == expected
  end
end
