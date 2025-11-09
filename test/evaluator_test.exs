defmodule EvaluatorTest do
  use ExUnit.Case
  doctest Monkeylang.Evaluator

  test "test basic parsing" do
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
end
