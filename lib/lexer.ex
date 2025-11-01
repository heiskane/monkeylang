defmodule Monkeylang.Lexer do
  alias Monkeylang.Token

  @keywords %{
    "fn" => :function,
    "let" => :let,
    "true" => true,
    "false" => false,
    "if" => :if,
    "else" => :else,
    "return" => :return
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

  # handle equals
  defp do_tokenize(["=" | ["=" | next_tail]], tokens),
    do: do_tokenize(next_tail, [Token.new(:equals, "==") | tokens])

  # handle assign
  defp do_tokenize(["=" | tail], tokens),
    do: do_tokenize(tail, [Token.new(:assign, "=") | tokens])

  # handle not equals
  defp do_tokenize(["!" | ["=" | next_tail]], tokens),
    do: do_tokenize(next_tail, [Token.new(:notequals, "!=") | tokens])

  # handle bang
  defp do_tokenize(["!" | tail], tokens),
    do: do_tokenize(tail, [Token.new(:bang, "!") | tokens])

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
        "-" -> Token.new(:minus, char)
        "/" -> Token.new(:slash, char)
        "<" -> Token.new(:lt, char)
        ">" -> Token.new(:gt, char)
        "*" -> Token.new(:asterisk, char)
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
