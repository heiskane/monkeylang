defmodule Monkeylang.Lexer do
  defstruct [:input, position: 0, read_position: 0, ch: 0]

  alias Monkeylang.Token

  @keywords %{
    fn: :function,
    let: :let
  }

  defmacro is_digit(ch) do
    quote do
      "0" <= unquote(ch) and unquote(ch) <= "9"
    end
  end

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
    ch =
      case lexer.read_position >= String.length(lexer.input) do
        true -> ""
        false -> String.at(lexer.input, lexer.read_position)
      end

    %__MODULE__{
      input: lexer.input,
      read_position: lexer.read_position + 1,
      position: lexer.position + 1,
      ch: ch
    }
  end

  def next_token(%__MODULE__{} = lexer) when is_letter(lexer.ch) do
    { lexer, identifier } = read_identifier(lexer)
    token_type = Map.get(@keywords, identifier, :ident)
    token = Token.new(token_type, identifier)
    { lexer, token }
  end

  def next_token(%__MODULE__{} = lexer) when is_digit(lexer.ch) do
    { lexer, number } = read_number(lexer)
    { lexer, Token.new(:int, number) }
  end

  def next_token(%__MODULE__{} = lexer) do
    case lexer.ch do
      "=" -> { lexer, Token.new(:assign, lexer.ch) }
      "+" -> { lexer, Token.new(:plus, lexer.ch) }
      "(" -> { lexer, Token.new(:lparen, lexer.ch) }
      ")" -> { lexer, Token.new(:rparen, lexer.ch) }
      "{" -> { lexer, Token.new(:lbrace, lexer.ch) }
      "}" -> { lexer, Token.new(:rbrace, lexer.ch) }
      "," -> { lexer, Token.new(:comma, lexer.ch) }
      ";" -> { lexer, Token.new(:semicolon, lexer.ch) }
      "" -> { lexer, Token.new(:eof, lexer.ch) }
      _ -> { lexer, Token.new(:illegal, lexer.ch) }
    end
  end

  def skip_whitespace(%__MODULE__{} = lexer) when not is_whitespace(lexer.ch), do: lexer
  def skip_whitespace(%__MODULE__{} = lexer),
    do:
      read_char(lexer)
      |> skip_whitespace()

  def read_identifier(%__MODULE__{} = lexer), do: read_identifier(lexer, "")
  defp read_identifier(%__MODULE__{} = lexer, identifier) when not is_letter(lexer.ch),
    do: {lexer, identifier}

  defp read_identifier(%__MODULE__{} = lexer, identifier) do
    read_char(lexer)
    |> read_identifier(identifier <> lexer.ch)
  end

  def read_number(%__MODULE__{} = lexer), do: read_number(lexer, "")
  defp read_number(%__MODULE__{} = lexer, number) when not is_digit(lexer.ch),
    do: {lexer, number}

  defp read_number(%__MODULE__{} = lexer, number) do
    read_char(lexer)
    |> read_number(number <> lexer.ch)
  end
end
