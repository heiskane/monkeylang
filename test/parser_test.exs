defmodule ParserTest do
  use ExUnit.Case
  doctest Monkeylang.Parser

  test "test basic parsing" do
    input = """
      1 + 2 + 3
    """

    {program, _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    [node | _] = program.statements

    # |> dbg()

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

    {program, _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

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
    assert program.statements == expected
  end

  test "test grouped" do
    input = """
      (1 + 2) * 3;
    """

    {program, _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    [node | _] = program.statements

    expected = %Monkeylang.AST.InfixExpression{
      token: %Monkeylang.Token{type: :asterisk, literal: "*", precedence: 4},
      operator: "*",
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

    # IO.puts(node)

    assert node == expected
  end

  test "test if else" do
    input = """
      if (x < y) { x } else { y };
    """

    {program, _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    [node | _] = program.statements

    expected =
      %Monkeylang.AST.IfExpression{
        token: %Monkeylang.Token{type: :if, literal: "if", precedence: 0},
        condition: %Monkeylang.AST.InfixExpression{
          token: %Monkeylang.Token{type: :lt, literal: "<", precedence: 2},
          operator: "<",
          left: %Monkeylang.AST.Ident{
            token: %Monkeylang.Token{type: :ident, literal: "x", precedence: 0},
            value: "x"
          },
          right: %Monkeylang.AST.Ident{
            token: %Monkeylang.Token{type: :ident, literal: "y", precedence: 0},
            value: "y"
          }
        },
        consequence: %Monkeylang.AST.BlockStatement{
          token: %Monkeylang.Token{type: :lbrace, literal: "{", precedence: 0},
          statements: [
            %Monkeylang.AST.Ident{
              token: %Monkeylang.Token{type: :ident, literal: "x", precedence: 0},
              value: "x"
            }
          ]
        },
        alternative: %Monkeylang.AST.BlockStatement{
          token: %Monkeylang.Token{type: :lbrace, literal: "{", precedence: 0},
          statements: [
            %Monkeylang.AST.Ident{
              token: %Monkeylang.Token{type: :ident, literal: "y", precedence: 0},
              value: "y"
            }
          ]
        }
      }

    assert node == expected
  end

  test "test function" do
    input = """
      fn(a, b) { return a > b };
    """

    {program, _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    [node | _] = program.statements

    expected = %Monkeylang.AST.FunctionLiteral{
      token: %Monkeylang.Token{type: :function, literal: "fn", precedence: 0},
      parameters: [
        %Monkeylang.AST.Ident{
          token: %Monkeylang.Token{type: :ident, literal: "a", precedence: 0},
          value: "a"
        },
        %Monkeylang.AST.Ident{
          token: %Monkeylang.Token{type: :ident, literal: "b", precedence: 0},
          value: "b"
        }
      ],
      body: %Monkeylang.AST.BlockStatement{
        token: %Monkeylang.Token{type: :lbrace, literal: "{", precedence: 0},
        statements: [
          %Monkeylang.AST.Return{
            token: %Monkeylang.Token{
              type: :return,
              literal: "return",
              precedence: 0
            },
            value: %Monkeylang.AST.InfixExpression{
              token: %Monkeylang.Token{type: :gt, literal: ">", precedence: 2},
              operator: ">",
              left: %Monkeylang.AST.Ident{
                token: %Monkeylang.Token{
                  type: :ident,
                  literal: "a",
                  precedence: 0
                },
                value: "a"
              },
              right: %Monkeylang.AST.Ident{
                token: %Monkeylang.Token{
                  type: :ident,
                  literal: "b",
                  precedence: 0
                },
                value: "b"
              }
            }
          }
        ]
      }
    }

    assert node == expected
  end

  test "test function without params" do
    input = """
      fn() { return 1 + 1};
    """

    {program, _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    [node | _] = program.statements

    expected = %Monkeylang.AST.FunctionLiteral{
      token: %Monkeylang.Token{type: :function, literal: "fn", precedence: 0},
      parameters: [],
      body: %Monkeylang.AST.BlockStatement{
        token: %Monkeylang.Token{type: :lbrace, literal: "{", precedence: 0},
        statements: [
          %Monkeylang.AST.Return{
            token: %Monkeylang.Token{
              type: :return,
              literal: "return",
              precedence: 0
            },
            value: %Monkeylang.AST.InfixExpression{
              token: %Monkeylang.Token{type: :plus, literal: "+", precedence: 3},
              operator: "+",
              left: %Monkeylang.AST.Integer{
                token: %Monkeylang.Token{type: :int, literal: "1", precedence: 0},
                value: 1
              },
              right: %Monkeylang.AST.Integer{
                token: %Monkeylang.Token{type: :int, literal: "1", precedence: 0},
                value: 1
              }
            }
          }
        ]
      }
    }

    assert node == expected
  end

  test "test call expression" do
    input = """
      add(1, 2 * 3, add(4 + 5 * 1, -2));
    """

    {program, _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    [node | _] = program.statements

    expected = %Monkeylang.AST.CallExpression{
      token: %Monkeylang.Token{type: :lparen, literal: "(", precedence: 6},
      function: %Monkeylang.AST.Ident{
        token: %Monkeylang.Token{type: :ident, literal: "add", precedence: 0},
        value: "add"
      },
      arguments: [
        %Monkeylang.AST.Integer{
          token: %Monkeylang.Token{type: :int, literal: "1", precedence: 0},
          value: 1
        },
        %Monkeylang.AST.InfixExpression{
          token: %Monkeylang.Token{type: :asterisk, literal: "*", precedence: 4},
          operator: "*",
          left: %Monkeylang.AST.Integer{
            token: %Monkeylang.Token{type: :int, literal: "2", precedence: 0},
            value: 2
          },
          right: %Monkeylang.AST.Integer{
            token: %Monkeylang.Token{type: :int, literal: "3", precedence: 0},
            value: 3
          }
        },
        %Monkeylang.AST.CallExpression{
          token: %Monkeylang.Token{type: :lparen, literal: "(", precedence: 6},
          function: %Monkeylang.AST.Ident{
            token: %Monkeylang.Token{type: :ident, literal: "add", precedence: 0},
            value: "add"
          },
          arguments: [
            %Monkeylang.AST.InfixExpression{
              token: %Monkeylang.Token{type: :plus, literal: "+", precedence: 3},
              operator: "+",
              left: %Monkeylang.AST.Integer{
                token: %Monkeylang.Token{type: :int, literal: "4", precedence: 0},
                value: 4
              },
              right: %Monkeylang.AST.InfixExpression{
                token: %Monkeylang.Token{
                  type: :asterisk,
                  literal: "*",
                  precedence: 4
                },
                operator: "*",
                left: %Monkeylang.AST.Integer{
                  token: %Monkeylang.Token{
                    type: :int,
                    literal: "5",
                    precedence: 0
                  },
                  value: 5
                },
                right: %Monkeylang.AST.Integer{
                  token: %Monkeylang.Token{
                    type: :int,
                    literal: "1",
                    precedence: 0
                  },
                  value: 1
                }
              }
            },
            %Monkeylang.AST.PrefixExpression{
              token: %Monkeylang.Token{type: :minus, literal: "-", precedence: 3},
              operator: "-",
              right: %Monkeylang.AST.Integer{
                token: %Monkeylang.Token{type: :int, literal: "2", precedence: 0},
                value: 2
              }
            }
          ]
        }
      ]
    }

    assert node == expected
  end

  test "test let" do
    input = """
      let asdf = 1;
    """

    {program, _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    [node | _] = program.statements

    expected = %Monkeylang.AST.Let{
      name: "asdf",
      value: %Monkeylang.AST.Integer{
        value: 1,
        token: %Monkeylang.Token{type: :int, literal: "1", precedence: 0}
      },
      token: %Monkeylang.Token{type: :let, literal: "let", precedence: 0}
    }

    assert node == expected
  end
end
