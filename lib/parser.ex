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

    rest =
      case rest do
        [] -> []
        [_ | tail] -> tail
      end

    parse_statements(rest, [statement | statements], errors)
  end

  defp parse_statement(tokens = [%Token{type: :let} | _], errors) do
    handle_let(tokens, errors)
  end

  defp parse_statement(tokens = [%Token{type: :return} | _], errors) do
    handle_return(tokens, errors)
  end

  defp parse_statement(tokens, errors),
    do: parse_expression(tokens, 0, errors)

  defp parse_prefix([token = %Token{type: :ident} | tail], errors) do
    node = %Monkeylang.AST.Ident{token: token, value: token.literal}
    {tail, node, errors}
  end

  defp parse_prefix([token = %Token{type: :int} | tail], errors) do
    node = %Monkeylang.AST.Integer{token: token, value: String.to_integer(token.literal)}
    {tail, node, errors}
  end

  defp parse_prefix([token = %Token{type: :if} | tail], errors) do
    {tokens, condition, errors} =
      parse_expression(tail, 0, errors)

    {tokens, block, errors} = parse_block(tokens, errors)

    {tokens, alternative, errors} =
      case hd(tokens).type do
        :else -> parse_block(tl(tokens), errors)
        _ -> {tokens, nil, errors}
      end

    node = %Monkeylang.AST.IfExpression{
      token: token,
      condition: condition,
      consequence: block,
      alternative: alternative
    }

    {tokens, node, errors}
  end

  defp parse_prefix(tokens = [%Token{type: :function}, next | _], errors)
       when next.type != :lparen,
       do: {tokens, nil, ["expected :lparen got #{next.type}" | errors]}

  defp parse_prefix([token = %Token{type: :function}, _lparen | tail], errors) do
    {tokens, params, errors} = parse_function_params(tail, errors, [])
    {tokens, block, errors} = parse_block(tokens, errors)

    function = %Monkeylang.AST.FunctionLiteral{
      token: token,
      parameters: params,
      body: block
    }

    {tokens, function, errors}
  end

  defp parse_prefix([token | tail], errors) when token.type in [:minus, :bang] do
    {tokens, right, errors} =
      parse_expression(tail, get_precedence(token.type), errors)

    node = %Monkeylang.AST.PrefixExpression{token: token, operator: token.literal, right: right}
    {tokens, node, errors}
  end

  defp parse_prefix([token | tail], errors)
       when token.type in [true, false] do
    node = %Monkeylang.AST.Boolean{token: token, value: token.type}
    {tail, node, errors}
  end

  defp parse_prefix([%Token{type: :lparen} | tail], errors) do
    {tokens, expression, errors} =
      parse_expression(tail, 0, errors)

    with {:ok, tokens} <- assert_peek(tokens, :rparen) do
      {tokens, expression, errors}
    else
      {:error, error} -> {tokens, expression, [error | errors]}
    end

    case hd(tokens).type do
      :rparen -> {tl(tokens), expression, errors}
      _ -> {tokens, nil, errors}
    end
  end

  defp parse_prefix([token | tail], errors) do
    {tail, nil, ["cant parse prefix #{token.type}" | errors]}
  end

  defp parse_expression(tokens, precedence, errors) do
    {tokens, left, errors} =
      parse_prefix(tokens, errors)
      |> dbg()

    parse_infix(tokens, left, precedence, errors)
  end

  defp parse_infix(tokens, nil, _precedence, errors),
    do: {tokens, nil, ["no left side for infix" | errors]}

  defp parse_infix(tokens = [next | _], left, precedence, errors)
       when next.type not in @infixable or not (precedence < next.precedence),
       do: {tokens, left, errors}

  defp parse_infix(tokens, left, precedence, errors) do
    [next | tail] = tokens
    {tokens, right, errors} = parse_expression(tail, next.precedence, errors)

    infix = %Monkeylang.AST.InfixExpression{
      token: next,
      operator: next.literal,
      left: left,
      right: right
    }

    parse_infix(tokens, infix, precedence, errors)
  end

  defp parse_block(tokens = [head | _], errors) do
    with {:ok, tokens} <- assert_peek(tokens, :lbrace) do
      {tokens, statements, errors} = parse_block_statements(tokens, errors, [])
      block = %Monkeylang.AST.BlockStatement{token: head, statements: statements}
      {tokens, block, errors}
    else
      {:error, msg} -> {tokens, nil, [msg | errors]}
    end
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

  defp parse_function_params([%Token{type: :rparen} | tail], errors, params),
    do: {tail, Enum.reverse(params), errors}

  defp parse_function_params([%Token{type: :comma} | tail], errors, params),
    do: parse_function_params(tail, errors, params)

  defp parse_function_params(tokens, errors, params) do
    {tokens, node, errors} = parse_prefix(tokens, errors)
    parse_function_params(tokens, errors, [node | params])
  end

  defp handle_return([token = %Token{type: :return} | tail], errors) do
    {tokens, expression, errors} = parse_expression(tail, hd(tail).precedence, errors)
    node = %Monkeylang.AST.Return{token: token, value: expression}
    {tokens, node, errors}
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

  defp assert_peek([%Token{type: type} | tail], expected) do
    case type == expected do
      true -> {:ok, tail}
      false -> {:error, "expected #{expected} but got #{type}"}
    end
  end

  defp get_precedence(type), do: Map.get(@precedences, type, 0)
end
