defmodule Monkeylang.LexerOld do
  defstruct [:input, position: 0, read_position: 0, ch: nil]

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
    |> read_char()
  end

  def tokenize(%__MODULE__{} = lexer), do: do_tokenize(lexer, [])

  defp do_tokenize(%__MODULE__{} = _lexer, tokens) when hd(tokens).type == :eof,
    do: Enum.reverse(tokens)

  defp do_tokenize(%__MODULE__{} = lexer, tokens) do
    {lexer, token} = next_token(lexer)
    do_tokenize(lexer, [token | tokens])
  end

  def next_token(%__MODULE__{} = lexer) do
    lexer
    |> skip_whitespace()
    |> parse_token()
  end

  defp parse_token(%__MODULE__{} = lexer) do
    case lexer.ch do
      "=" -> { read_char(lexer), Token.new(:assign, lexer.ch)}
      "+" -> { read_char(lexer), Token.new(:plus, lexer.ch)}
      "(" -> { read_char(lexer), Token.new(:lparen, lexer.ch)}
      ")" -> { read_char(lexer), Token.new(:rparen, lexer.ch)}
      "{" -> { read_char(lexer), Token.new(:lbrace, lexer.ch)}
      "}" -> { read_char(lexer), Token.new(:rbrace, lexer.ch)}
      "," -> { read_char(lexer), Token.new(:comma, lexer.ch)}
      ";" -> { read_char(lexer), Token.new(:semicolon, lexer.ch)}
      "" -> { read_char(lexer), Token.new(:eof, lexer.ch)}
      _ -> cond do
        is_letter(lexer.ch) ->
          {lexer, identifier} = read_identifier(lexer)
          token_type = Map.get(@keywords, identifier, :ident)
          {lexer, Token.new(token_type, identifier)}
        is_digit(lexer.ch) ->
          {lexer, number} = read_number(lexer)
          {lexer, Token.new(:int, number)}
        true -> { read_char(lexer), Token.new(:illegal, lexer.ch) }
      end
    end
  end

  defp read_char(%__MODULE__{input: input, read_position: pos} = lexer) do
    ch =
      case pos >= String.length(input) do
        true -> ""
        false -> String.at(input, pos)
      end

    %__MODULE__{
      input: input,
      read_position: pos + 1,
      position: lexer.read_position,
      ch: ch
    }
  end

  defp skip_whitespace(%__MODULE__{} = lexer) when not is_whitespace(lexer.ch), do: lexer

  defp skip_whitespace(%__MODULE__{} = lexer),
    do:
      read_char(lexer)
      |> skip_whitespace()

  defp read_identifier(%__MODULE__{} = lexer), do: do_read_identifier(lexer, "")

  defp do_read_identifier(%__MODULE__{} = lexer, identifier) when not is_letter(lexer.ch),
    do: {lexer, identifier}

  defp do_read_identifier(%__MODULE__{} = lexer, identifier) do
    read_char(lexer)
    |> do_read_identifier(identifier <> lexer.ch)
  end

  defp read_number(%__MODULE__{} = lexer), do: read_number(lexer, "")

  defp read_number(%__MODULE__{} = lexer, number) when not is_digit(lexer.ch),
    do: {lexer, number}

  defp read_number(%__MODULE__{} = lexer, number) do
    read_char(lexer)
    |> read_number(number <> lexer.ch)
  end
end
