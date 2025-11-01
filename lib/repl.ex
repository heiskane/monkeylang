defmodule Monkeylang.Repl do
  def start do
    IO.gets("monke>")
    |> Monkeylang.Lexer.tokenize()
    |> IO.inspect()
    start()
  end
end
