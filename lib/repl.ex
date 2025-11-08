defmodule Monkeylang.Repl do
  def start do
    {statements, errors} =
      IO.gets("monke> ")
      |> Monkeylang.Lexer.tokenize()
      |> Monkeylang.Parser.parse_tokens()
      # |> dbg()

    Enum.each(errors, &IO.puts/1)
    Enum.each(statements, &IO.puts/1)
    start()
  end
end
