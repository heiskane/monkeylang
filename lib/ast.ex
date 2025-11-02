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
          value: term()
        }
end

defmodule Monkeylang.AST.Return do
  @enforce_keys [:token, :value]
  defstruct [:token, :value]

  @type t :: %__MODULE__{
          token: Monkeylang.Token.t(),
          value: term()
        }
end

defmodule Monkeylang.AST.Ident do
  @enforce_keys [:token, :value]
  defstruct [:token, :value]

  @type t :: %__MODULE__{
          token: Monkeylang.Token.t(),
          value: String.t()
        }
end

defmodule Monkeylang.AST.Integer do
  @enforce_keys [:token, :value]
  defstruct [:token, :value]

  @type t :: %__MODULE__{
          token: Monkeylang.Token.t(),
          value: Integer.t()
        }
end

defmodule Monkeylang.AST.PrefixExpression do
  @enforce_keys [:token, :operator, :right]
  defstruct [:token, :operator, :right]

  @type t :: %__MODULE__{
          token: Monkeylang.Token.t(),
          operator: term(),
          right: term()
        }
end

defmodule Monkeylang.AST.InfixExpression do
  @enforce_keys [:token, :operator, :left, :right]
  defstruct [:token, :operator, :left, :right]

  @type t :: %__MODULE__{
          token: Monkeylang.Token.t(),
          operator: term(),
          left: term(),
          right: term()
        }
end
