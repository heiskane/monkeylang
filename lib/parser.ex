defmodule Monkeylang.Parser do
  alias Monkeylang.Token
  alias Monkeylang.AST.Program

  @infixable [
    :plus,
    :minus,
    :slash,
    :asterisk,
    :equals,
    :notequals,
    :lt,
    :gt,
    :lparen,
    :lbracket
  ]

  @spec parse_tokens(list(Token.t())) :: {Program.t(), list(String.t())}
  def parse_tokens(tokens) do
    {statements, errors} = parse_statements(tokens, [], [])
    program = %Monkeylang.AST.Program{statements: statements}
    {program, errors}
  end

  defp parse_statements([], statements, errors),
    do: {Enum.reverse(statements), errors}

  defp parse_statements([%Token{type: :eof} | _], statements, errors),
    do: {Enum.reverse(statements), errors}

  # semicolons are optional
  defp parse_statements([%Token{type: :semicolon} | tail], statements, errors),
    do: parse_statements(tail, statements, errors)

  defp parse_statements(tokens, statements, errors) do
    {rest, statement, errors} = parse_statement(tokens, errors)
    rest = Enum.drop(rest, 1)
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

  defp parse_prefix([token = %Token{type: :string} | tail], errors) do
    node = %Monkeylang.AST.String{token: token, value: token.literal}
    {tail, node, errors}
  end

  defp parse_prefix([token = %Token{type: :ident} | tail], errors) do
    node = %Monkeylang.AST.Ident{token: token, value: token.literal}
    {tail, node, errors}
  end

  defp parse_prefix([token = %Token{type: :int} | tail], errors) do
    node = %Monkeylang.AST.Integer{token: token, value: String.to_integer(token.literal)}
    {tail, node, errors}
  end

  defp parse_prefix([token = %Token{type: :if} | tail], errors) do
    {tokens, condition, errors} = parse_expression(tail, 0, errors)
    {tokens, block, errors} = parse_block(tokens, errors)

    {tokens, alternative, errors} =
      case tokens do
        [%Token{type: :else} | tail] -> parse_block(tail, errors)
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
      parse_expression(tail, Token.get_precedence(token.type), errors)

    node = %Monkeylang.AST.PrefixExpression{token: token, operator: token.literal, right: right}
    {tokens, node, errors}
  end

  defp parse_prefix([token | tail], errors)
       when token.type in [true, false] do
    node = %Monkeylang.AST.Boolean{token: token, value: token.type}
    {tail, node, errors}
  end

  defp parse_prefix([token = %Token{type: :lbracket} | tail], errors) do
    {tokens, expressions, errors} = parse_expression_list(tail, :rbracket, errors, [])
    node = %Monkeylang.AST.ArrayLiteral{token: token, elements: expressions}
    {tokens, node, errors}
  end

  defp parse_prefix([%Token{type: :lparen} | tail], errors) do
    {tokens, expression, errors} =
      parse_expression(tail, 0, errors)

    with {:ok, tokens} <- assert_peek(tokens, :rparen) do
      {tokens, expression, errors}
    else
      {:error, error} -> {tokens, expression, [error | errors]}
    end

    case tokens do
      [%Token{type: :rparen} | tail] -> {tail, expression, errors}
      _ -> {tokens, nil, errors}
    end
  end

  defp parse_prefix([token | tail], errors) do
    {tail, nil, ["cant parse prefix #{token.type}" | errors]}
  end

  defp parse_expression(tokens, precedence, errors) do
    {tokens, left, errors} = parse_prefix(tokens, errors)
    parse_infix(tokens, left, precedence, errors)
  end

  defp parse_infix(tokens, nil, _precedence, errors),
    do: {tokens, nil, ["no left side for infix" | errors]}

  defp parse_infix(tokens = [next | _], left, precedence, errors)
       when next.type not in @infixable or not (precedence < next.precedence) do
    {tokens, left, errors}
  end

  defp parse_infix([token = %Token{type: :lparen} | tail], function, _precedence, errors) do
    {tokens, arguments, errors} = parse_expression_list(tail, :rparen, errors, [])
    node = %Monkeylang.AST.CallExpression{token: token, function: function, arguments: arguments}
    {tokens, node, errors}
  end

  defp parse_infix([next | tail], left, precedence, errors) do
    {tokens, right, errors} = parse_expression(tail, next.precedence, errors)

    infix = %Monkeylang.AST.InfixExpression{
      token: next,
      operator: next.literal,
      left: left,
      right: right
    }

    parse_infix(tokens, infix, precedence, errors)
  end

  defp parse_block([head = %Token{type: :lbrace} | tail], errors) do
    {tokens, statements, errors} = parse_block_statements(tail, errors, [])
    block = %Monkeylang.AST.BlockStatement{token: head, statements: statements}
    {tokens, block, errors}
  end

  defp parse_block_statements([head | tail], errors, statements)
       when head.type in [:rbrace, :eof] do
    {tail, Enum.reverse(statements), errors}
  end

  defp parse_block_statements([%Token{type: :semicolon} | tail], errors, statements) do
    parse_block_statements(tail, errors, statements)
  end

  defp parse_block_statements(tokens, errors, statements) do
    {tail, statement, errors} =
      parse_statement(tokens, errors)

    parse_block_statements(tail, errors, [statement | statements])
  end

  defp parse_function_params([%Token{type: :rparen} | tail], errors, params),
    do: {tail, Enum.reverse(params), errors}

  defp parse_function_params([%Token{type: :comma} | tail], errors, params),
    do: parse_function_params(tail, errors, params)

  defp parse_function_params(tokens, errors, params) do
    {tokens, node, errors} = parse_prefix(tokens, errors)
    parse_function_params(tokens, errors, [node | params])
  end

  defp parse_expression_list([%Token{type: type} | tail], ender, errors, acc) when type == ender,
    do: {tail, Enum.reverse(acc), errors}

  defp parse_expression_list([%Token{type: :comma} | tail], ender, errors, acc),
    do: parse_expression_list(tail, ender, errors, acc)

  defp parse_expression_list(tokens, ender, errors, acc) do
    {tokens, expression, errors} = parse_expression(tokens, 0, errors)
    parse_expression_list(tokens, ender, errors, [expression | acc])
  end

  defp handle_return([token = %Token{type: :return} | tail], errors) do
    {tokens, expression, errors} = parse_expression(tail, token.precedence, errors)
    node = %Monkeylang.AST.Return{token: token, value: expression}
    {tokens, node, errors}
  end

  defp handle_let(
         [
           token = %Token{type: :let},
           %Token{type: :ident, literal: name},
           %Token{type: :assign} | tail
         ],
         errors
       ) do
    {tokens, expression, errors} = parse_expression(tail, token.precedence, errors)

    node = %Monkeylang.AST.Let{
      token: token,
      name: name,
      value: expression
    }

    {tokens, node, errors}
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
end
