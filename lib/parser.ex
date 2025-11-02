defmodule Monkeylang.Parser do
  alias Monkeylang.Token

  @precedences %{
    :equals => 1,
    :notequals => 1,
    :lt => 2,
    :gt => 2,
    :plus => 3,
    :minus => 3,
    :slash => 4,
    :asterisk => 4,
    :prefix => 5,
    :lparen => 6
  }

  @infixable [
    :plus,
    :minus,
    :slash,
    :asterisk,
    :eq,
    :not_eq,
    :lt,
    :gt
    # TODO: lparen
  ]

  defp get_precedence(type), do: Map.get(@precedences, type, 0)

  def parse_tokens(tokens), do: parse_statements(tokens, [], [])

  defp parse_statements([], statements, errors),
    do: {Enum.reverse(statements), errors}

  defp parse_statements([%Token{type: :eof} | _], statements, errors),
    do: {Enum.reverse(statements), errors}

  defp parse_statements(tokens = [%Token{type: :let} | _], statements, errors) do
    {node, rest, errors} = handle_let(tokens, errors)
    parse_statements(rest, [node | statements], errors)
  end

  defp parse_statements(tokens = [%Token{type: :return} | _], statements, errors) do
    {node, rest, errors} = handle_return(tokens, errors)
    parse_statements(rest, [node | statements], errors)
  end

  # semicolons are optional lol
  # TODO: is this necessary?
  defp parse_statements([%Token{type: :semicolon} | tail], statements, errors),
    do: parse_statements(tail, statements, errors)

  defp parse_statements(tokens, statements, errors) do
    {rest, expression, errors} =
      parse_expression(tokens, 0, errors)
      |> dbg()

    parse_statements(tl(rest), [expression | statements], errors)
    |> dbg()
  end

  # TODO: this is really just `parse_prefix`
  defp parse_token(tokens = [token = %Token{type: :int} | _], :prefix, errors) do
    node = %Monkeylang.AST.Integer{token: token, value: String.to_integer(token.literal)}
    {tokens, node, errors}
  end

  defp parse_token(tokens = [token | _], type, errors) do
    IO.puts("cant parse token #{token.type} as #{type}")
    {tokens, nil, errors}
  end

  @spec parse_expression(list(Token.t()), integer(), list(String.t())) ::
          {list(Token.t()), Token.t(), list(String.t())}
  defp parse_expression(tokens, precedence, errors) do
    # dbg({hd(tokens), precedence})
    {tokens = [curr, next | tail], left, errors} =
      parse_token(tokens, :prefix, errors)
      |> dbg()

    if is_nil(left) do
      {tokens, left, errors}
    else
      case {precedence < get_precedence(next.type), next.type in @infixable} do
        {false, _} ->
          {tokens, left, errors}

        {true, false} ->
          {tokens, left, errors}

        {true, true} ->
          # TODO: handle :lparen
          {tokens, right, errors} = parse_expression(tail, get_precedence(next.type), errors)

          infix = %Monkeylang.AST.InfixExpression{
            token: next,
            operator: next.literal,
            left: left,
            right: right
          }

          {tokens, infix, errors}
      end
    end
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
