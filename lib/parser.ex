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
    :equals,
    :notequals,
    :lt,
    :gt
    # TODO: lparen
  ]

  def parse_tokens(tokens), do: parse_statements(tokens, [], [])

  defp parse_statements([], statements, errors),
    do: {Enum.reverse(statements), errors}

  defp parse_statements([%Token{type: :eof} | _], statements, errors),
    do: {Enum.reverse(statements), errors}

  # semicolons are optional lol
  defp parse_statements([%Token{type: :semicolon} | tail], statements, errors),
    do: parse_statements(tail, statements, errors)

  defp parse_statements(tokens, statements, errors) do
    {rest, statement, errors} = parse_statement(tokens, errors)
    parse_statements(tl(rest), [statement | statements], errors)
  end

  defp parse_statement(tokens = [%Token{type: :let} | _], errors) do
    handle_let(tokens, errors)
  end

  defp parse_statement(tokens = [%Token{type: :return} | _], errors) do
    handle_return(tokens, errors)
  end

  defp parse_statement(tokens, errors),
    do: parse_expression(tokens, 0, errors)

  defp parse_prefix(tokens = [token = %Token{type: :ident} | _], errors) do
    node = %Monkeylang.AST.Ident{token: token, value: token.literal}
    {tokens, node, errors}
  end

  defp parse_prefix(tokens = [token = %Token{type: :int} | _], errors) do
    node = %Monkeylang.AST.Integer{token: token, value: String.to_integer(token.literal)}
    {tokens, node, errors}
  end

  defp parse_prefix([token = %Token{type: :if} | tail], errors) do
    # node = %Monkeylang.AST.Integer{token: token, value: String.to_integer(token.literal)}
    # TODO: add with statement?
    # TODO: make sure :lparen is next
    {tokens, condition, errors} = parse_expression(tail, 0, errors)

    # TODO: make sure :rparen is next
    # TODO: make sure :rbrace is next
    {tokens, block, errors} = parse_block(tl(tokens), errors)
    {tokens, alternative, errors} = parse_else(tl(tokens), errors)

    node = %Monkeylang.AST.IfExpression{
      token: token,
      condition: condition,
      consequence: block,
      alternative: alternative
    }

    {tokens, node, errors}
  end

  defp parse_prefix([token | tail], errors) when token.type in [:minus, :bang] do
    {tokens, right, errors} = parse_expression(tail, get_precedence(token.type), errors)
    node = %Monkeylang.AST.PrefixExpression{token: token, operator: token.literal, right: right}
    {tokens, node, errors}
  end

  defp parse_prefix(tokens = [token | _], errors)
       when token.type in [true, false] do
    node = %Monkeylang.AST.Boolean{token: token, value: token.type}
    {tokens, node, errors}
  end

  defp parse_prefix([%Token{type: :lparen} | tail], errors) do
    {tokens, expression, errors} = parse_expression(tail, 0, errors)
    {next, _} = peek_token(tokens)

    case next.type do
      :rparen -> {tl(tokens), expression, errors}
      _ -> {tokens, nil, errors}
    end
  end

  defp parse_prefix(tokens = [token | _], errors) do
    {tokens, nil, ["cant parse prefix #{token.type}" | errors]}
  end

  defp parse_else([%Token{type: :else} | tail], errors) do
    {tokens, block, errors} = parse_block(tail, errors)
  end

  defp parse_else(tokens, errors), do: {tokens, nil, errors}

  defp parse_block([head | tail], errors) do
    {tokens, statements, errors} = parse_block_statements(tail, errors, [])
    block = %Monkeylang.AST.BlockStatement{token: head, statements: statements}
    {tokens, block, errors}
  end

  defp parse_block_statements(tokens = [head | _], errors, statements)
       when head.type in [:rbrace, :eof] do
    {tokens, Enum.reverse(statements), errors}
  end

  defp parse_block_statements(tokens, errors, statements) do
    {tail, statement, errors} =
      parse_statement(tokens, errors)

    {tl(tail), [statement | statements], errors}
  end

  defp parse_expression(tokens, precedence, errors) do
    {tokens, left, errors} = parse_prefix(tokens, errors)
    parse_infix(tokens, left, precedence, errors)
  end

  defp parse_infix(tokens, nil, _precedence, errors),
    do: {tokens, nil, errors}

  defp parse_infix(tokens = [_, next | _], left, precedence, errors)
       when next.type not in @infixable or not (precedence < next.precedence),
       do: {tokens, left, errors}

  defp parse_infix(tokens, left, precedence, errors) do
    {next, tail} = peek_token(tokens)
    {tokens, right, errors} = parse_expression(tail, next.precedence, errors)

    infix = %Monkeylang.AST.InfixExpression{
      token: next,
      operator: next.literal,
      left: left,
      right: right
    }

    parse_infix(tokens, infix, precedence, errors)
  end

  defp handle_return([token = %Token{type: :return} | tail], errors) do
    node = %Monkeylang.AST.Return{token: token, value: "todo"}

    tail =
      Enum.split_while(tail, &(&1.type != :semicolon))
      |> elem(1)
      |> tl()

    {tail, node, errors}
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

    {tail, node, errors}
  end

  defp handle_let([%Token{type: :let} | tail], errors) do
    # TODO: utilize `with` statements to make this nice?
    message =
      cond do
        length(tail) < 3 -> "not enough tokens for a let statement"
        (token = Enum.at(tail, 0)).type != :ident -> "expected identifier but got #{token.type}"
        (token = Enum.at(tail, 1)).type != :assign -> "expected assign but got #{token.type}"
      end

    {tail, nil, [message | errors]}
  end

  defp get_precedence(type), do: Map.get(@precedences, type, 0)
  defp peek_token([_, next | tail]), do: {next, tail}

  # Not sure about this
  # defp expect_type(%Token{type: type}, expected) do
  #   case type != expected do
  #     True -> "expected #{expected} got #{type}"
  #     False -> nil
  #   end
  # end
end
