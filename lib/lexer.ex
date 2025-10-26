defmodule Monkeylang.Lexer do
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

  # TODO: handle `==` and `!=`
  @spec tokenize(String.t()) :: list(Token.t())
  def tokenize(input) do
    String.graphemes(input)
    |> do_tokenize([])
  end

  defp do_tokenize([], tokens),
    do: Enum.reverse([Token.new(:eof, "") | tokens])

  defp do_tokenize([char | tail], tokens) when is_whitespace(char),
    do: do_tokenize(tail, tokens)

  defp do_tokenize([char | tail], tokens) when is_letter(char) do
    {ident, rest} = read_ident(tail, char)
    token_type = Map.get(@keywords, ident, :ident)
    token = Token.new(token_type, ident)
    do_tokenize(rest, [ token | tokens])
  end

  defp do_tokenize([char | tail], tokens) when is_digit(char) do
    {number, rest} = read_number(tail, char)
    token = Token.new(:int, number)
    do_tokenize(rest, [ token | tokens])
  end

  defp do_tokenize([char | tail], tokens) when char == "=" do
    case hd(tail) do
      "=" ->
        token = Token.new(:equals, "==")
        do_tokenize(tl(tail), [ token | tokens ])
      _ ->
        token = Token.new(:assign, char)
        do_tokenize(tail, [ token | tokens ])
    end
  end

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

  defp read_number(input = [ char | _tail ], number) when not is_digit(char), do: {number, input}
  defp read_number([char | tail], number), do: read_number(tail, number <> char)

  defp read_ident(input = [ char | _tail ], ident) when not is_letter(char), do: {ident, input}
  defp read_ident([char | tail], ident), do: read_ident(tail, ident <> char)
end
