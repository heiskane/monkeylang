defmodule Monkeylang.Object do
  @enforce_keys [:type, :value]
  defstruct [:type, :value]

  @type t :: %__MODULE__{
          type: atom(),
          value: term()
        }
end

defmodule Monkeylang.Evaluator do
  alias Monkeylang.AST
  alias Monkeylang.Object

  def evaluate(node = %AST.Integer{}),
    do: %Object{type: :integer, value: node.value}

  def evaluate(node = %AST.Boolean{}),
    # TODO: somehow reuse boolean objects
    do: %Object{type: :boolean, value: node.value}

  def evaluate(node = %AST.PrefixExpression{}) do
    right = evaluate(node.right)
    eval_prefix(node.token.type, right)
  end

  def evaluate(nil),
    do: %Object{type: :null, value: nil}

  # TODO: what is this supposed to do??
  def evaluate(%AST.Program{statements: statements}) do
    case length(statements) > 0 do
      true -> evaluate(hd(statements))
      false -> nil
    end
  end

  def evaluate(node) do
    raise "cannot handle node #{inspect(node)}"
  end

  def eval_prefix(:bang, %Object{type: :boolean, value: value}),
    do: %Object{type: :boolean, value: not value}

  def eval_prefix(:bang, %Object{type: type}),
    do: raise("type #{type} not supported for `!`-operator")

  def eval_prefix(:minus, %Object{type: :integer, value: value}),
    do: %Object{type: :integer, value: -value}
end
