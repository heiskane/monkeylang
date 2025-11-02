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

  test "test booleans" do
    input = """
      3 < 5 == true;
      true != false;
    """

    {statements, _errors} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()
      |> dbg()

    expected = [
      %Monkeylang.AST.InfixExpression{
        token: %Monkeylang.Token{type: :equals, literal: "==", precedence: 1},
        operator: "==",
        left: %Monkeylang.AST.InfixExpression{
          token: %Monkeylang.Token{type: :lt, literal: "<", precedence: 2},
          operator: "<",
          left: %Monkeylang.AST.Integer{
            token: %Monkeylang.Token{type: :int, literal: "3", precedence: 0},
            value: 3
          },
          right: %Monkeylang.AST.Integer{
            token: %Monkeylang.Token{type: :int, literal: "5", precedence: 0},
            value: 5
          }
        },
        right: %Monkeylang.AST.Boolean{
          token: %Monkeylang.Token{type: true, literal: "true", precedence: 0},
          value: true
        }
      },
      %Monkeylang.AST.InfixExpression{
        token: %Monkeylang.Token{type: :notequals, literal: "!=", precedence: 1},
        operator: "!=",
        left: %Monkeylang.AST.Boolean{
          token: %Monkeylang.Token{type: true, literal: "true", precedence: 0},
          value: true
        },
        right: %Monkeylang.AST.Boolean{
          token: %Monkeylang.Token{type: false, literal: "false", precedence: 0},
          value: false
        }
      }
    ]

    # IO.puts(hd(statements))
    # IO.puts(hd(tl(statements)))
    assert statements == expected
  end
end
