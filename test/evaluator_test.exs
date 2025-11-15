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

  test "test let statement" do
    env = Monkeylang.Environment.new()

    {_output, env} =
      Monkeylang.Lexer.tokenize("let a = 123;")
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate(env)

    assert Monkeylang.Environment.get(env, "a") == %Monkeylang.Object{type: :integer, value: 123}

    input = """
      let a = 123;
      let b = 456;
      let c = a * b;
    """

    {_output, env} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate(env)

    assert Monkeylang.Environment.get(env, "c") == %Monkeylang.Object{
             type: :integer,
             value: 56088
           }
  end

  test "test function" do
    env = Monkeylang.Environment.new()

    input = """
      let add = fn(a, b) { return a + b };
      add(1 + 1, 2);
    """

    {output, _env} =
      Monkeylang.Lexer.tokenize(input)
      |> Monkeylang.Parser.parse_tokens()
      |> elem(0)
      |> Monkeylang.Evaluator.evaluate(env)

    assert output == %Monkeylang.Object{
             type: :integer,
             value: 4
           }
  end
end
