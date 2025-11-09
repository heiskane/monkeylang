defmodule EvaluatorTest do
  use ExUnit.Case
  doctest Monkeylang.Evaluator

  test "test return in nested statement" do
    input = """
    if (10 > 1) {
      if (10 > 1) {
        return 10;
      }

      return 1;
    }
    """

    {program, []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    result = Monkeylang.Evaluator.evaluate(program)
    assert result == %Monkeylang.Object{type: :integer, value: 10}
  end

  test "test basic error" do
    input = """
      true + 1
    """

    {program, []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    %Monkeylang.Error{} = Monkeylang.Evaluator.evaluate(program)
  end

  test "test error early exit" do
    input = """
      true + 1;
      1 + 1;
    """

    {program, []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    %Monkeylang.Error{} = Monkeylang.Evaluator.evaluate(program)
  end

  test "test more errors" do
    %Monkeylang.Error{} =
      Monkeylang.Lexer.tokenize("true + true")
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate()

    %Monkeylang.Error{} =
      Monkeylang.Lexer.tokenize("true * true")
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate()

    %Monkeylang.Error{} =
      Monkeylang.Lexer.tokenize("true / true")
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate()

    %Monkeylang.Error{} =
      Monkeylang.Lexer.tokenize("true - true")
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate()

    %Monkeylang.Error{} =
      Monkeylang.Lexer.tokenize("true < true")
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate()

    %Monkeylang.Error{} =
      Monkeylang.Lexer.tokenize("true > true")
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate()
  end
end
