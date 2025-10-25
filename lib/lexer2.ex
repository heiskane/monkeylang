defmodule Monkeylang.Lexer2 do
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

  def tokenize(input) do
    String.graphemes(input)
    |> do_tokenize([])
    |> Enum.reverse()
  end

  defp do_tokenize([], tokens), do:
    [ Token.new(:eof, "") |  tokens ]

  defp do_tokenize([ char | tail ], tokens) when is_whitespace(char),
    do: do_tokenize(tail, tokens)

  defp do_tokenize([ char | tail ], tokens) when is_letter(char) do
    { ident, rest } = read_ident(tail, char)
    token_type = Map.get(@keywords, ident, :ident)
    do_tokenize(rest, [ Token.new(token_type, ident) | tokens ])
  end

  defp do_tokenize([ char | tail ], tokens) when is_digit(char) do
    { number, rest } = read_number(tail, char)
    do_tokenize(rest, [ Token.new(:int, number) | tokens ])
  end

  defp do_tokenize([ char | tail ], tokens) do
    token = case char do
      "=" -> Token.new(:assign, char)
      "+" -> Token.new(:plus, char)
      "(" -> Token.new(:lparen, char)
      ")" -> Token.new(:rparen, char)
      "{" -> Token.new(:lbrace, char)
      "}" -> Token.new(:rbrace, char)
      "," -> Token.new(:comma, char)
      ";" -> Token.new(:semicolon, char)
      "" -> Token.new(:eof, char)
      _ -> Token.new(:illegal, char)
    end
    do_tokenize(tail, [ token | tokens ])
  end

  defp read_number(input, number) when not is_digit(hd(input)), do: { number, input }
  defp read_number([ char | tail ], number), do: read_number(tail, number <> char)

  defp read_ident(input, ident) when not is_letter(hd(input)), do: { ident, input }
  defp read_ident([ char | tail ], ident), do: read_ident(tail, ident <> char)
end
