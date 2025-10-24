defmodule Monkeylang.Lexer do
  defstruct [:input, position: 0, readPosition: 0, ch: 0]

  alias Monkeylang.Token

  @keywords %{
    fn: :function,
    let: :let,
  }

  defmacro is_letter(ch) do
    quote do
      ("a" <= unquote(ch) and unquote(ch) <= "z") or
        ("A" <= unquote(ch) and unquote(ch) <= "Z") or
        unquote(ch) == "_"
    end
  end

  defmacro is_whitespace(ch) do
    quote do
      unquote(ch) == " " or
      unquote(ch) == "\t" or
      unquote(ch) == "\n" or
      unquote(ch) == "\r"
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
      ch: String.at(lexer.input, lexer.readPosition)
    }
  end

  defp skip_whitespace(%__MODULE__{} = lexer) when not is_whitespace(lexer.ch), do: lexer
  defp skip_whitespace(%__MODULE__{} = lexer), do:
    read_char(lexer)
    |> skip_whitespace()

  def next_token(%__MODULE__{} = lexer) do
    lexer =
      lexer
      |> read_char()
      |> skip_whitespace()

    token = case lexer.ch do
      "=" -> Token.new(:assign, lexer.ch)
      "+" -> Token.new(:plus, lexer.ch)
      "(" -> Token.new(:lparen, lexer.ch)
      ")" -> Token.new(:rparen, lexer.ch)
      "{" -> Token.new(:lbrace, lexer.ch)
      "}" -> Token.new(:rbrace, lexer.ch)
      "," -> Token.new(:comma, lexer.ch)
      ";" -> Token.new(:semicolon, lexer.ch)
      "" -> Token.new(:eof, lexer.ch)
      _ -> case is_letter(lexer.ch) do
        true ->
          { lexer, identifier } = read_identifier(lexer)
          Map.get(@keywords, identifier, :ident)
          |> Token.new(identifier)
        false -> Token.new(:illegal, lexer.ch)
      end
    end

    {lexer, token}
  end

  def read_identifier(%__MODULE__{} = lexer) do
    read_identifier(lexer, "")
  end

  defp read_identifier(%__MODULE__{} = lexer, identifier) when not is_letter(lexer.ch),
    do: { lexer, identifier }

  defp read_identifier(%__MODULE__{} = lexer, identifier) do
    read_char(lexer)
    |> read_identifier(identifier <> lexer.ch)
  end

  defp is_digit(ch), do: "0" <= ch && ch <= "9"
end
