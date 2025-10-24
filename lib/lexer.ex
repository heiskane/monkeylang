defmodule Monkeylang.Lexer do
  defstruct [:input, position: 0, readPosition: 0, ch: 0]

  alias Monkeylang.Token

  def new(input) do
    %__MODULE__{input: input}
  end

  def parse(input) do end

  def read_char(%__MODULE__{} = lexer) do
    %__MODULE__{
      input: lexer.input,
      readPosition: lexer.readPosition + 1,
      position: lexer.position + 1,
      ch: String.at(lexer.input, lexer.readPosition),
    }
  end

  def next_token(%__MODULE__{} = lexer) do
    { lexer, Token.from_string(lexer.ch) }
  end
end
