defmodule Monkeylang.Evaluator do
  def evaluate(node) do
  end
end

defmodule Monkeylang.Object do
  defstruct [:type, :value]

  @type t :: %__MODULE__{
          type: atom(),
          value: term()
        }
end
