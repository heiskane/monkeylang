defmodule ParserTest do
  use ExUnit.Case
  doctest Monkeylang.Parser

  test "test basic parsing" do
    input = """
      1 + 2 + 3
    """

    {[node | _], _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()
      |> dbg()

    expected = %Monkeylang.AST.InfixExpression{
      token: %Monkeylang.Token{type: :plus, literal: "+", precedence: 3},
      operator: "+",
      left: %Monkeylang.AST.InfixExpression{
        token: %Monkeylang.Token{type: :plus, literal: "+", precedence: 3},
        operator: "+",
        left: %Monkeylang.AST.Integer{
          token: %Monkeylang.Token{type: :int, literal: "1", precedence: 0},
          value: 1
        },
        right: %Monkeylang.AST.Integer{
          token: %Monkeylang.Token{type: :int, literal: "2", precedence: 0},
          value: 2
        }
      },
      right: %Monkeylang.AST.Integer{
        token: %Monkeylang.Token{type: :int, literal: "3", precedence: 0},
        value: 3
      }
    }

    assert node == expected
  end
end
