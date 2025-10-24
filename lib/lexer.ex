defmodule Monkeylang.Lexer do
  defstruct [:input, position: 0, readPosition: 0, ch: 0]

  alias Monkeylang.Token

  defmacro is_letter(ch) do
    quote do
      ("a" <= unquote(ch) and unquote(ch) <= "z") or
      ("A" <= unquote(ch) and unquote(ch) <= "Z") or
      (unquote(ch) == "_")
    end
  end

  def new(input) do
    %__MODULE__{input: input}
  end

  def read_char(%__MODULE__{} = lexer) do
    %__MODULE__{
      input: lexer.input,
      readPosition: lexer.readPosition + 1,
      position: lexer.position + 1,
      ch: String.at(lexer.input, lexer.readPosition),
    }
  end

  def next_token(%__MODULE__{} = lexer) do
    lexer = lexer
    |> read_char()
    { lexer, Token.from_string(lexer.ch) }
  end

  def read_identifier(%__MODULE__{} = lexer) do
    read_identifier(lexer, "")
  end

  defp read_identifier(%__MODULE__{} = lexer, identifier) when not is_letter(lexer.ch), do: identifier
  defp read_identifier(%__MODULE__{} = lexer, identifier) do
    read_char(lexer)
    |> read_identifier(identifier <> lexer.ch)
  end

  defp is_digit(ch), do: "0" <= ch && ch <= "9"
end

lexer = Monkeylang.Lexer.new("asdf qwer")
Monkeylang.Lexer.read_char(lexer)
|> Monkeylang.Lexer.read_identifier()
|> dbg()
