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

  defp do_parse_tokens(tokens = [%Token{type: :return} | _], statements, errors) do
    {node, rest, errors} = handle_return(tokens, errors)
    do_parse_tokens(rest, [node | statements], errors)
  end

  # semicolons are optional lol
  defp do_parse_tokens([%Token{type: :semicolon} | tail], statements, errors),
    do: do_parse_tokens(tail, statements, errors)

  # default
  defp do_parse_tokens(tokens, statements, errors) do
    # TODO: add precedence
    {rest, expression, errors} =
      parse_expression(tokens, :prefix, errors)
      |> dbg()

    do_parse_tokens(rest, [expression | statements], errors)
  end

  defp parse_expression(tokens = [token = %Token{type: :ident} | _tail], :prefix, errors),
    do: {
      tokens,
      %Monkeylang.AST.Ident{token: token, value: token.literal},
      errors
    }

  defp parse_expression(tokens = [token = %Token{type: :int} | _tail], :prefix, errors),
    do: {
      tokens,
      %Monkeylang.AST.Integer{token: token, value: String.to_integer(token.literal)},
      errors
    }

  defp parse_expression([token | tail], :prefix, errors)
       when token.type in [:bang, :minus] do
    next_expression = parse_expression(tail, :prefix, errors)

    {
      tail,
      %Monkeylang.AST.PrefixExpression{
        token: token,
        operator: token.literal,
        right: next_expression
      },
      errors
    }
  end

  defp parse_expression(tokens = [token | _], type, errors) do
    {tokens, nil, ["no implementation for #{token.type} - #{type}" | errors]}
  end

  defp handle_return([token = %Token{type: :return} | tail], errors) do
    node = %Monkeylang.AST.Return{token: token, value: "todo"}

    tail =
      Enum.split_while(tail, &(&1.type != :semicolon))
      |> elem(1)
      |> tl()

    {node, tail, errors}
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

  defp handle_let([%Token{type: :let} | tail], errors) do
    # TODO: utilize `with` statements to make this nice?
    message =
      cond do
        length(tail) < 3 -> "not enough tokens for a let statement"
        (token = Enum.at(tail, 0)).type != :ident -> "expected identifier but got #{token.type}"
        (token = Enum.at(tail, 1)).type != :assign -> "expected assign but got #{token.type}"
      end

    {nil, tail, [message | errors]}
  end

  # Not sure about this
  # defp expect_type(%Token{type: type}, expected) do
  #   case type != expected do
  #     True -> "expected #{expected} got #{type}"
  #     False -> nil
  #   end
  # end
end
