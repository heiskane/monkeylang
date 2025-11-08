defmodule Monkeylang.Repl do
  def start do
    {program, errors} =
      IO.gets("monke> ")
      |> Monkeylang.Lexer.tokenize()
      |> Monkeylang.Parser.parse_tokens()
      # |> dbg()

    Enum.each(errors, &IO.puts/1)

    IO.puts(program)

    Monkeylang.Evaluator.evaluate(program)
    |> dbg()

    start()
  end
end
