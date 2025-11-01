# TODO: define protocol for node/statement/expression etc.

defmodule Monkeylang.AST.Program do
  @enforce_keys [:statements]
  defstruct [:statements]

  @type t :: %__MODULE__{statements: term()}
end

defmodule Monkeylang.AST.Let do
  @enforce_keys [:token, :name, :value]
  defstruct [:token, :name, :value]

  @type t :: %__MODULE__{
    token: Monkeylang.Token.t(),
    name: term(),
    value: term(),
  }
end
