defmodule Monkeylang.Object do
  @enforce_keys [:type, :value]
  defstruct [:type, :value]

  @type t :: %__MODULE__{
          type: atom(),
          value: term()
        }
end

defmodule Monkeylang.Evaluator do
  alias Monkeylang.AST.Integer
  alias Monkeylang.AST.Boolean
  alias Monkeylang.Object

  def evaluate(node = %Integer{}),
    do: %Object{type: :integer, value: node.value}

  def evaluate(node = %Boolean{}),
    do: %Object{type: :boolean, value: node.value}

  # def evaluate(node = %Boolean{}),
  #   do: %Object{type: :boolean, value: node.value}

  def evaluate(node) do
    raise "unknown node type"
  end
end
