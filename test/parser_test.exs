defmodule ParserTest do
  use ExUnit.Case
  doctest Monkeylang.Parser

  test "basic parsing" do
    input = """
      1 + 2 + 3
    """

    {program, _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    [node | _] = program.statements

    # |> dbg()

    expected = %Monkeylang.AST.InfixExpression{
      token: %Monkeylang.Token{type: :plus, literal: "+"},
      operator: "+",
      left: %Monkeylang.AST.InfixExpression{
        token: %Monkeylang.Token{type: :plus, literal: "+"},
        operator: "+",
        left: %Monkeylang.AST.Integer{
          token: %Monkeylang.Token{type: :int, literal: "1"},
          value: 1
        },
        right: %Monkeylang.AST.Integer{
          token: %Monkeylang.Token{type: :int, literal: "2"},
          value: 2
        }
      },
      right: %Monkeylang.AST.Integer{
        token: %Monkeylang.Token{type: :int, literal: "3"},
        value: 3
      }
    }

    assert node == expected
  end

  test "booleans" do
    input = """
      3 < 5 == true;
      true != false;
    """

    {program, _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    expected = [
      %Monkeylang.AST.InfixExpression{
        token: %Monkeylang.Token{type: :equals, literal: "=="},
        operator: "==",
        left: %Monkeylang.AST.InfixExpression{
          token: %Monkeylang.Token{type: :lt, literal: "<"},
          operator: "<",
          left: %Monkeylang.AST.Integer{
            token: %Monkeylang.Token{type: :int, literal: "3"},
            value: 3
          },
          right: %Monkeylang.AST.Integer{
            token: %Monkeylang.Token{type: :int, literal: "5"},
            value: 5
          }
        },
        right: %Monkeylang.AST.Boolean{
          token: %Monkeylang.Token{type: true, literal: "true"},
          value: true
        }
      },
      %Monkeylang.AST.InfixExpression{
        token: %Monkeylang.Token{type: :notequals, literal: "!="},
        operator: "!=",
        left: %Monkeylang.AST.Boolean{
          token: %Monkeylang.Token{type: true, literal: "true"},
          value: true
        },
        right: %Monkeylang.AST.Boolean{
          token: %Monkeylang.Token{type: false, literal: "false"},
          value: false
        }
      }
    ]

    # IO.puts(hd(statements))
    # IO.puts(hd(tl(statements)))
    assert program.statements == expected
  end

  test "grouped" do
    input = """
      (1 + 2) * 3;
    """

    {program, _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    [node | _] = program.statements

    expected = %Monkeylang.AST.InfixExpression{
      token: %Monkeylang.Token{type: :asterisk, literal: "*"},
      operator: "*",
      left: %Monkeylang.AST.InfixExpression{
        token: %Monkeylang.Token{type: :plus, literal: "+"},
        operator: "+",
        left: %Monkeylang.AST.Integer{
          token: %Monkeylang.Token{type: :int, literal: "1"},
          value: 1
        },
        right: %Monkeylang.AST.Integer{
          token: %Monkeylang.Token{type: :int, literal: "2"},
          value: 2
        }
      },
      right: %Monkeylang.AST.Integer{
        token: %Monkeylang.Token{type: :int, literal: "3"},
        value: 3
      }
    }

    # IO.puts(node)

    assert node == expected
  end

  test "if else" do
    input = """
      if (x < y) { x } else { y };
    """

    {program, _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    [node | _] = program.statements

    expected =
      %Monkeylang.AST.IfExpression{
        token: %Monkeylang.Token{type: :if, literal: "if"},
        condition: %Monkeylang.AST.InfixExpression{
          token: %Monkeylang.Token{type: :lt, literal: "<"},
          operator: "<",
          left: %Monkeylang.AST.Ident{
            token: %Monkeylang.Token{type: :ident, literal: "x"},
            value: "x"
          },
          right: %Monkeylang.AST.Ident{
            token: %Monkeylang.Token{type: :ident, literal: "y"},
            value: "y"
          }
        },
        consequence: %Monkeylang.AST.BlockStatement{
          token: %Monkeylang.Token{type: :lbrace, literal: "{"},
          statements: [
            %Monkeylang.AST.Ident{
              token: %Monkeylang.Token{type: :ident, literal: "x"},
              value: "x"
            }
          ]
        },
        alternative: %Monkeylang.AST.BlockStatement{
          token: %Monkeylang.Token{type: :lbrace, literal: "{"},
          statements: [
            %Monkeylang.AST.Ident{
              token: %Monkeylang.Token{type: :ident, literal: "y"},
              value: "y"
            }
          ]
        }
      }

    assert node == expected
  end

  test "function" do
    input = """
      fn(a, b) { return a > b };
    """

    {program, _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    [node | _] = program.statements

    expected = %Monkeylang.AST.FunctionLiteral{
      token: %Monkeylang.Token{type: :function, literal: "fn"},
      parameters: [
        %Monkeylang.AST.Ident{
          token: %Monkeylang.Token{type: :ident, literal: "a"},
          value: "a"
        },
        %Monkeylang.AST.Ident{
          token: %Monkeylang.Token{type: :ident, literal: "b"},
          value: "b"
        }
      ],
      body: %Monkeylang.AST.BlockStatement{
        token: %Monkeylang.Token{type: :lbrace, literal: "{"},
        statements: [
          %Monkeylang.AST.Return{
            token: %Monkeylang.Token{
              type: :return,
              literal: "return"
            },
            value: %Monkeylang.AST.InfixExpression{
              token: %Monkeylang.Token{type: :gt, literal: ">"},
              operator: ">",
              left: %Monkeylang.AST.Ident{
                token: %Monkeylang.Token{
                  type: :ident,
                  literal: "a"
                },
                value: "a"
              },
              right: %Monkeylang.AST.Ident{
                token: %Monkeylang.Token{
                  type: :ident,
                  literal: "b"
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
      token: %Monkeylang.Token{type: :function, literal: "fn"},
      parameters: [],
      body: %Monkeylang.AST.BlockStatement{
        token: %Monkeylang.Token{type: :lbrace, literal: "{"},
        statements: [
          %Monkeylang.AST.Return{
            token: %Monkeylang.Token{
              type: :return,
              literal: "return"
            },
            value: %Monkeylang.AST.InfixExpression{
              token: %Monkeylang.Token{type: :plus, literal: "+"},
              operator: "+",
              left: %Monkeylang.AST.Integer{
                token: %Monkeylang.Token{type: :int, literal: "1"},
                value: 1
              },
              right: %Monkeylang.AST.Integer{
                token: %Monkeylang.Token{type: :int, literal: "1"},
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
      token: %Monkeylang.Token{type: :lparen, literal: "("},
      function: %Monkeylang.AST.Ident{
        token: %Monkeylang.Token{type: :ident, literal: "add"},
        value: "add"
      },
      arguments: [
        %Monkeylang.AST.Integer{
          token: %Monkeylang.Token{type: :int, literal: "1"},
          value: 1
        },
        %Monkeylang.AST.InfixExpression{
          token: %Monkeylang.Token{type: :asterisk, literal: "*"},
          operator: "*",
          left: %Monkeylang.AST.Integer{
            token: %Monkeylang.Token{type: :int, literal: "2"},
            value: 2
          },
          right: %Monkeylang.AST.Integer{
            token: %Monkeylang.Token{type: :int, literal: "3"},
            value: 3
          }
        },
        %Monkeylang.AST.CallExpression{
          token: %Monkeylang.Token{type: :lparen, literal: "("},
          function: %Monkeylang.AST.Ident{
            token: %Monkeylang.Token{type: :ident, literal: "add"},
            value: "add"
          },
          arguments: [
            %Monkeylang.AST.InfixExpression{
              token: %Monkeylang.Token{type: :plus, literal: "+"},
              operator: "+",
              left: %Monkeylang.AST.Integer{
                token: %Monkeylang.Token{type: :int, literal: "4"},
                value: 4
              },
              right: %Monkeylang.AST.InfixExpression{
                token: %Monkeylang.Token{
                  type: :asterisk,
                  literal: "*"
                },
                operator: "*",
                left: %Monkeylang.AST.Integer{
                  token: %Monkeylang.Token{
                    type: :int,
                    literal: "5"
                  },
                  value: 5
                },
                right: %Monkeylang.AST.Integer{
                  token: %Monkeylang.Token{
                    type: :int,
                    literal: "1"
                  },
                  value: 1
                }
              }
            },
            %Monkeylang.AST.PrefixExpression{
              token: %Monkeylang.Token{type: :minus, literal: "-"},
              operator: "-",
              right: %Monkeylang.AST.Integer{
                token: %Monkeylang.Token{type: :int, literal: "2"},
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
        token: %Monkeylang.Token{type: :int, literal: "1"}
      },
      token: %Monkeylang.Token{type: :let, literal: "let"}
    }

    assert node == expected
  end

  test "test strings" do
    input = """
      let a = "hello world";
    """

    {%Monkeylang.AST.Program{statements: [node]}, []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    expected = %Monkeylang.AST.Let{
      name: "a",
      token: %Monkeylang.Token{type: :let, literal: "let"},
      value: %Monkeylang.AST.String{
        token: %Monkeylang.Token{type: :string, literal: "hello world"},
        value: "hello world"
      }
    }

    assert node == expected
  end

  test "arrays" do
    input = """
      ["hello", "world", 1];
    """

    {%Monkeylang.AST.Program{statements: [node]}, _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    expected = %Monkeylang.AST.ArrayLiteral{
      token: %Monkeylang.Token{type: :lbracket, literal: "["},
      elements: [
        %Monkeylang.AST.String{
          token: %Monkeylang.Token{
            type: :string,
            literal: "hello"
          },
          value: "hello"
        },
        %Monkeylang.AST.String{
          token: %Monkeylang.Token{
            type: :string,
            literal: "world"
          },
          value: "world"
        },
        %Monkeylang.AST.Integer{
          token: %Monkeylang.Token{type: :int, literal: "1"},
          value: 1
        }
      ]
    }

    assert node == expected

    input = """
      hello[0]
    """

    {program, _errors = []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    expected = %Monkeylang.AST.Program{
      statements: [
        %Monkeylang.AST.InfixExpression{
          token: %Monkeylang.Token{type: :lbracket, literal: "["},
          operator: "[",
          left: %Monkeylang.AST.Ident{
            token: %Monkeylang.Token{type: :ident, literal: "hello"},
            value: "hello"
          },
          right: %Monkeylang.AST.Integer{
            token: %Monkeylang.Token{type: :int, literal: "0"},
            value: 0
          }
        }
      ]
    }

    assert program == expected
  end
end
