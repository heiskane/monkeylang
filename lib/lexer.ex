defmodule Monkeylang.Lexer do
  defstruct [:input, position: 0, readPosition: 0, ch: 0]

  def new(input) do
    %__MODULE__{input: input}
  end

  def parse(input) do end

  def read_char(%__MODULE__{} = lexer) do
    dbg(lexer)
    {
      lexer
      |> Map.update!(:readPosition, &(&1 + 1))
      |> Map.update!(:position, &(&1 + 1)), # TODO: should be set to readPosition
      String.at(lexer.input, lexer.readPosition)
    }
  end
end
