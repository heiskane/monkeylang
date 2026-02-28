defmodule Monkeylang.Repl do
  def start() do
    env = Monkeylang.Environment.new()
    loop(env)
  end

  def loop(env) do
    {program, errors} =
      IO.gets("monke> ")
      |> Monkeylang.Lexer.tokenize()
      |> Monkeylang.Parser.parse_tokens()
      # |> dbg()

    Enum.each(errors, &IO.puts/1)

    IO.puts(program)

    {value, env} =
      Monkeylang.Evaluator.evaluate(program, env)

    dbg(value)

    loop(env)
  end
end
