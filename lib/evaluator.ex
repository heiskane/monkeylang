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

defmodule Monkeylang.Evaluator do
  alias Monkeylang.AST
  alias Monkeylang.Object
  alias Monkeylang.ReturnValue

  def evaluate(node = %AST.Integer{}),
    do: %Object{type: :integer, value: node.value}

  def evaluate(node = %AST.Return{}) do
    value = evaluate(node.value)
    %ReturnValue{value: value}
  end

  def evaluate(node = %AST.Boolean{}),
    # TODO: somehow reuse boolean objects
    do: %Object{type: :boolean, value: node.value}

  def evaluate(node = %AST.PrefixExpression{}) do
    right = evaluate(node.right)
    eval_prefix(node.token.type, right)
  end

  def evaluate(node = %AST.InfixExpression{}) do
    left = evaluate(node.left)
    right = evaluate(node.right)
    eval_infix(node.token.type, left, right)
  end

  def evaluate(node = %AST.IfExpression{}) do
    condition = evaluate(node.condition)

    case condition do
      %Object{type: :boolean, value: true} -> evaluate(node.consequence)
      %Object{type: :boolean, value: false} -> evaluate(node.alternative)
      _ -> raise "if condition did not evaluate to a boolean, #{inspect(condition)}"
    end
  end

  def evaluate(obj = %Object{type: :null}), do: obj
  def evaluate(nil), do: %Object{type: :null, value: nil}

  def evaluate(%AST.BlockStatement{statements: statements}) do
    Enum.reduce_while(statements, %Object{type: :null, value: nil}, fn
      result, _ = %ReturnValue{} -> {:halt, result}
      node, _ -> {:cont, evaluate(node)}
    end)
  end

  def evaluate(%AST.Program{statements: statements}) do
    Enum.reduce_while(statements, %Object{type: :null, value: nil}, fn
      result, _ = %ReturnValue{} -> {:halt, result.value}
      node, _ -> {:cont, evaluate(node)}
    end)
  end

  def evaluate(node) do
    raise "cannot handle node #{inspect(node)}"
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
    do: %Object{type: :boolean, value: left.value < right.value}

  defp eval_infix(:gt, left = %Object{type: :integer}, right = %Object{type: :integer}),
    do: %Object{type: :boolean, value: left.value > right.value}

  defp eval_infix(:equals, left = %Object{}, right = %Object{}) when left.type != right.type,
    do: %Object{type: :boolean, value: false}

  defp eval_infix(:equals, left = %Object{}, right = %Object{}) when left.type == right.type,
    do: %Object{type: left.type, value: left.value == right.value}

  defp eval_infix(:notequals, left = %Object{}, right = %Object{}),
    do: %Object{type: :boolean, value: left.value != right.value}

  defp eval_prefix(:bang, %Object{type: :boolean, value: value}),
    do: %Object{type: :boolean, value: not value}

  defp eval_prefix(:bang, %Object{type: type}),
    do: raise("type #{type} not supported for `!`-operator")

  defp eval_prefix(:minus, %Object{type: :integer, value: value}),
    do: %Object{type: :integer, value: -value}
end
