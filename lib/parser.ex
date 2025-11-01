defmodule Monkeylang.Parser do
  alias Monkeylang.Token

  def parse_tokens(tokens), do: do_parse_tokens(tokens, [])

  defp do_parse_tokens([], statements),
    do: Enum.reverse(statements)

  defp do_parse_tokens([%Token{type: :eof} | _], statements),
    do: Enum.reverse(statements)

  defp do_parse_tokens(tokens = [%Token{type: :let} | _], statements) do
    {node, rest} = handle_let(tokens)
    do_parse_tokens(rest, [node | statements])
  end

  defp do_parse_tokens([head | tail], statements) do
    do_parse_tokens(tail, statements)
  end

  defp handle_let([
         token = %Token{type: :let},
         ident = %Token{type: :ident},
         %Token{type: :assign} | tail
       ]) do
    node = %Monkeylang.AST.Let{
      token: token,
      name: ident,
      value: "todo"
    }

    # TODO: get value

    tail =
      Enum.split_while(tail, &(&1.type != :semicolon))
      |> elem(1)
      |> tl()

    {node, tail}
  end

  # TODO: add more descriptive error messages
  defp handle_let(_) do
    raise(ArgumentError, "invalid let statement")
  end
end
