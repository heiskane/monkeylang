defmodule Monkeylang.Object do
  @enforce_keys [:type, :value]
  defstruct [:type, :value]

  @type t :: %__MODULE__{
          type: atom(),
          value: term()
        }
end

defmodule Monkeylang.ReturnValue do
  @enforce_keys [:value]
  defstruct [:value]

  @type t :: %__MODULE__{value: term()}
end

defmodule Monkeylang.Function do
  @enforce_keys [:params, :body, :env]
  defstruct [:params, :body, :env]

  @type t :: %__MODULE__{params: list(), body: term(), env: term()}
end

defmodule Monkeylang.Error do
  @enforce_keys [:message]
  defstruct [:message]

  @type t :: %__MODULE__{message: String.t()}
end

defmodule Monkeylang.Evaluator do
  alias Monkeylang.AST
  alias Monkeylang.Error
  alias Monkeylang.Object
  alias Monkeylang.Function
  alias Monkeylang.ReturnValue
  alias Monkeylang.Environment

  # Less memory usage when these are pre-defined?
  @yea %Object{type: :boolean, value: true}
  @nah %Object{type: :boolean, value: false}

  @spec evaluate(term(), map()) :: {Object.t() | ReturnValue.t() | Error.t(), map()}
  def evaluate(node = %AST.Integer{}, env),
    do: {%Object{type: :integer, value: node.value}, env}

  def evaluate(node = %AST.String{}, env),
    do: {%Object{type: :string, value: node.value}, env}

  def evaluate(node = %AST.Return{}, env) do
    {value, env} = evaluate(node.value, env)

    case value do
      %Object{} = value -> {%ReturnValue{value: value}, env}
      %Error{} = value -> {value, env}
    end
  end

  def evaluate(node = %AST.Boolean{}, env), do: {to_boolean(node.value), env}

  def evaluate(node = %AST.PrefixExpression{}, env) do
    {right, env} = evaluate(node.right, env)

    case right do
      %Object{} = right -> {eval_prefix(node.token.type, right), env}
      %Error{} = right -> {right, env}
    end
  end

  def evaluate(node = %AST.InfixExpression{}, env) do
    with {%Object{} = left, env} <- evaluate(node.left, env),
         {%Object{} = right, env} <- evaluate(node.right, env) do
      value = eval_infix(node.token.type, left, right)
      {value, env}
    else
      {%Error{} = error, env} -> {error, env}
    end
  end

  def evaluate(node = %AST.IfExpression{}, env) do
    case evaluate(node.condition, env) do
      {%Error{} = error, env} ->
        {error, env}

      {@yea, env} ->
        evaluate(node.consequence, env)

      {@nah, env} ->
        evaluate(node.alternative, env)

      {node, env} ->
        {%Error{message: "if condition did not evaluate to a boolean, #{inspect(node)}"}, env}
    end
  end

  def evaluate(node = %AST.Let{}, env) do
    {object, env} = evaluate(node.value, env)
    env = Environment.set(env, node.name, object)
    {object, env}
  end

  def evaluate(node = %AST.Ident{}, env) do
    object = Environment.get(env, node.value)
    {object, env}
  end

  def evaluate(obj = %Object{type: :null}, env), do: {obj, env}
  def evaluate(nil, env), do: {%Object{type: :null, value: nil}, env}

  def evaluate(%AST.BlockStatement{statements: statements}, env),
    do: eval_block(statements, {%Object{type: :null, value: nil}, env})

  def evaluate(%AST.Program{statements: statements}, env),
    do: eval_program(statements, {%Object{type: :null, value: nil}, env})

  def evaluate(node = %AST.FunctionLiteral{}, env),
    do: {%Function{params: node.parameters, body: node.body, env: env}, env}

  def evaluate(node = %AST.CallExpression{}, env) do
    {function, env} = evaluate(node.function, env)

    case eval_expressions(node.arguments, [], env) do
      {:ok, {args, env}} -> {apply_function(function, args), env}
      {:error, error} -> error
    end
  end

  def evaluate(node = %Error{}, env), do: {node, env}

  def evaluate(node, env),
    do: {%Error{message: "no handler implemented for node #{inspect(node)}"}, env}

  def apply_function(function = %Function{}, args) when length(function.params) != length(args),
    do: %Error{
      message: "function params given #{length(args)}, needed #{length(function.params)}"
    }

  def apply_function(function = %Function{}, args) do
    env =
      Enum.zip(function.params, args)
      |> Enum.reduce(function.env, fn {name, value}, acc ->
        Environment.set(acc, name.value, value)
      end)

    # Dont care what happens to env inside the function scope
    {result, _env} = evaluate(function.body, env)

    result
  end

  defp eval_expressions([], results, env), do: {:ok, {results, env}}
  defp eval_expressions(_statements, [error = %Error{} | _tail], _env), do: {:error, error}

  defp eval_expressions([head | tail], results, env) do
    {result, env} = evaluate(head, env)
    eval_expressions(tail, [result | results], env)
  end

  defp eval_block([], {previous, env}), do: {previous, env}
  defp eval_block(_statements, {previous = %ReturnValue{}, env}), do: {previous, env}
  defp eval_block(_statements, {previous = %Error{}, env}), do: {previous, env}

  defp eval_block([head | tail], {_previous, env}) do
    {result, env} = evaluate(head, env)
    eval_block(tail, {result, env})
  end

  defp eval_program(_statements, {previous = %ReturnValue{}, env}), do: {previous.value, env}
  defp eval_program(_statements, {previous = %Error{}, env}), do: {previous, env}
  defp eval_program([], {previous, env}), do: {previous, env}

  defp eval_program([head | tail], {_previous, env}) do
    {result, env} = evaluate(head, env)
    eval_program(tail, {result, env})
  end

  defp eval_infix(token_type, left, right) when left.type != right.type,
    do: %Error{
      message: "type mismatch for operator #{token_type} with #{left.type} <> #{right.type}"
    }

  defp eval_infix(type, left, right)
       when type in [:plus, :minus, :asterisk, :slash, :lt, :gt] and
              not (left.type == :integer and right.type == :integer) do
    %Error{message: "operator type #{type} not supported for #{left.type} and #{right.type}"}
  end

  defp eval_infix(:plus, left = %Object{type: :integer}, right = %Object{type: :integer}),
    do: %Object{type: :integer, value: left.value + right.value}

  defp eval_infix(:minus, left = %Object{type: :integer}, right = %Object{type: :integer}),
    do: %Object{type: :integer, value: left.value - right.value}

  defp eval_infix(:asterisk, left = %Object{type: :integer}, right = %Object{type: :integer}),
    do: %Object{type: :integer, value: left.value * right.value}

  defp eval_infix(:slash, left = %Object{type: :integer}, right = %Object{type: :integer}),
    do: %Object{type: :integer, value: left.value / right.value}

  defp eval_infix(:lt, left = %Object{type: :integer}, right = %Object{type: :integer}),
    do: to_boolean(left.value < right.value)

  defp eval_infix(:gt, left = %Object{type: :integer}, right = %Object{type: :integer}),
    do: to_boolean(left.value > right.value)

  defp eval_infix(:equals, left = %Object{}, right = %Object{})
       when left.type != right.type,
       do: @nah

  defp eval_infix(:equals, left = %Object{}, right = %Object{}) when left.type == right.type,
    do: to_boolean(left.value == right.value)

  defp eval_infix(:notequals, left = %Object{}, right = %Object{}),
    do: to_boolean(left.value != right.value)

  defp eval_prefix(:bang, %Object{type: :boolean, value: value}),
    do: to_boolean(not value)

  defp eval_prefix(:bang, %Object{type: type}),
    do: %Monkeylang.Error{message: "type #{type} not supported for `!`-operator"}

  defp eval_prefix(:minus, %Object{type: :integer, value: value}),
    do: %Object{type: :integer, value: -value}

  defp eval_prefix(:minus, %Object{type: type}),
    do: %Error{message: "type #{type} not supported for `-`-operator"}

  defp to_boolean(true), do: @yea
  defp to_boolean(false), do: @nah
end
