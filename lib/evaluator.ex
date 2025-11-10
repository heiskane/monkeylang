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

defmodule Monkeylang.Error do
  @enforce_keys [:message]
  defstruct [:message]

  @type t :: %__MODULE__{message: String.t()}
end

defmodule Monkeylang.Evaluator do
  alias Monkeylang.AST
  alias Monkeylang.Error
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
      _ -> %Error{message: "if condition did not evaluate to a boolean, #{inspect(condition)}"}
    end
  end

  def evaluate(obj = %Object{type: :null}), do: obj
  def evaluate(nil), do: %Object{type: :null, value: nil}

  def evaluate(%AST.BlockStatement{statements: statements}),
    do: eval_block(statements, %Object{type: :null, value: nil})

  def evaluate(%AST.Program{statements: statements}),
    do: eval_program(statements, %Object{type: :null, value: nil})

  def evaluate(node = %Error{}), do: node
  def evaluate(node), do: %Error{message: "no handler implemented for node #{inspect(node)}"}

  defp eval_block([], previous), do: previous
  defp eval_block(_statements, previous = %ReturnValue{}), do: previous
  defp eval_block(_statements, previous = %Error{}), do: previous
  defp eval_block([head | tail], _previous), do: eval_block(tail, evaluate(head))

  defp eval_program(_statements, previous = %ReturnValue{}), do: previous.value
  defp eval_program(_statements, previous = %Error{}), do: previous
  defp eval_program([], previous), do: previous
  defp eval_program([head | tail], _previous), do: eval_program(tail, evaluate(head))

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
    do: %Monkeylang.Error{message: "type #{type} not supported for `!`-operator"}

  defp eval_prefix(:minus, %Object{type: :integer, value: value}),
    do: %Object{type: :integer, value: -value}

  defp eval_prefix(:minus, %Object{type: type}),
    do: %Error{message: "type #{type} not supported for `-`-operator"}
end
