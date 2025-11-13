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

    env = Monkeylang.Environment.new()
    {result, _env} = Monkeylang.Evaluator.evaluate(program, env)
    assert result == %Monkeylang.Object{type: :integer, value: 10}
  end

  test "test basic error" do
    input = """
      true + 1
    """

    {program, []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    env = Monkeylang.Environment.new()
    {%Monkeylang.Error{}, _env} = Monkeylang.Evaluator.evaluate(program, env)
  end

  test "test error early exit" do
    input = """
      true + 1;
      1 + 1;
    """

    {program, []} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()

    env = Monkeylang.Environment.new()
    {%Monkeylang.Error{}, _env} = Monkeylang.Evaluator.evaluate(program, env)
  end

  test "test more errors" do
    env = Monkeylang.Environment.new()

    {%Monkeylang.Error{}, _env} =
      Monkeylang.Lexer.tokenize("true + true")
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate(env)

    {%Monkeylang.Error{}, _env} =
      Monkeylang.Lexer.tokenize("true * true")
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate(env)

    {%Monkeylang.Error{}, _env} =
      Monkeylang.Lexer.tokenize("true / true")
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate(env)

    {%Monkeylang.Error{}, _env} =
      Monkeylang.Lexer.tokenize("true - true")
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate(env)

    {%Monkeylang.Error{}, _env} =
      Monkeylang.Lexer.tokenize("true < true")
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate(env)

    {%Monkeylang.Error{}, _env} =
      Monkeylang.Lexer.tokenize("true > true")
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate(env)
  end

  test "test prefix errors" do
    env = Monkeylang.Environment.new()

    {%Monkeylang.Error{}, _env} =
      Monkeylang.Lexer.tokenize("-true")
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate(env)

    {%Monkeylang.Error{}, _env} =
      Monkeylang.Lexer.tokenize("!5")
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate(env)
  end
end
