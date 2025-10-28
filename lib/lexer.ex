defmodule Monkeylang.Lexer do
  alias Monkeylang.Token

  @keywords %{
    "fn" => :function,
    "let" => :let
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

  @spec tokenize(String.t()) :: list(Token.t())
  def tokenize(input) do
    String.graphemes(input)
    |> do_tokenize([])
  end

  # handle eof
  defp do_tokenize([], tokens),
    do: Enum.reverse([Token.new(:eof, "") | tokens])

  # skip whitespace
  defp do_tokenize([char | tail], tokens) when is_whitespace(char),
    do: do_tokenize(tail, tokens)

  # handle identifiers
  defp do_tokenize([char | tail], tokens) when is_letter(char) do
    {ident, rest} = read_ident(tail, char)
    token_type = Map.get(@keywords, ident, :ident)
    token = Token.new(token_type, ident)
    do_tokenize(rest, [token | tokens])
  end

  # handle numbers
  defp do_tokenize([char | tail], tokens) when is_digit(char) do
    {number, rest} = read_number(tail, char)
    token = Token.new(:int, number)
    do_tokenize(rest, [token | tokens])
  end

  # handle assign or equals
  defp do_tokenize([char = "=" | tail = [next | next_tail]], tokens) do
    case next do
      "=" ->
        token = Token.new(:equals, "==")
        do_tokenize(next_tail, [token | tokens])

      _ ->
        token = Token.new(:assign, char)
        do_tokenize(tail, [token | tokens])
    end
  end

  # handle not equals or not
  defp do_tokenize([char = "!" | tail = [next | next_tail]], tokens) do
    case next do
      "=" ->
        token = Token.new(:unequals, "!=")
        do_tokenize(next_tail, [token | tokens])

      _ ->
        token = Token.new(:not, char)
        do_tokenize(tail, [token | tokens])
    end
  end

  # handle single charachter tokens
  defp do_tokenize([char | tail], tokens) do
    token =
      case char do
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

    do_tokenize(tail, [token | tokens])
  end

  defp read_number(input = [char | _tail], number) when not is_digit(char), do: {number, input}
  defp read_number([char | tail], number), do: read_number(tail, number <> char)

  defp read_ident(input = [char | _tail], ident) when not is_letter(char), do: {ident, input}
  defp read_ident([char | tail], ident), do: read_ident(tail, ident <> char)
end
