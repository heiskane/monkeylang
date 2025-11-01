defmodule Monkeylang.Parser do
  alias Monkeylang.Token

  def parse_tokens(tokens), do: do_parse_tokens(tokens, [], [])

  defp do_parse_tokens([], statements, errors),
    do: {Enum.reverse(statements), errors}

  defp do_parse_tokens([%Token{type: :eof} | _], statements, errors),
    do: {Enum.reverse(statements), errors}

  defp do_parse_tokens(tokens = [%Token{type: :let} | _], statements, errors) do
    {node, rest, errors} = handle_let(tokens, errors)
    do_parse_tokens(rest, [node | statements], errors)
  end

  defp do_parse_tokens([head | tail], statements, errors) do
    do_parse_tokens(tail, statements, errors)
  end

  defp handle_let(
         [
           token = %Token{type: :let},
           ident = %Token{type: :ident},
           %Token{type: :assign} | tail
         ],
         errors
       ) do
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

    {node, tail, errors}
  end

  defp handle_let([_ | tail], errors) do
    # TODO: add more descriptive error messages
    {nil, tail, ["let is no good" | errors]}
  end
end
