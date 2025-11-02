# TODO: define protocol for node/statement/expression etc.

defmodule Monkeylang.AST.Program do
  @enforce_keys [:statements]
  defstruct [:statements]

  @type t :: %__MODULE__{statements: term()}
end

defmodule Monkeylang.AST.ExpressionStatement do
  @enforce_keys [:token, :expression]
  defstruct [:token, :expression]

  @type t :: %__MODULE__{
          token: Monkeylang.Token.t(),
          expression: term()
        }
end

defmodule Monkeylang.AST.Let do
  @enforce_keys [:token, :name, :value]
  defstruct [:token, :name, :value]

  @type t :: %__MODULE__{
          token: Monkeylang.Token.t(),
          name: String.t(),
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

defimpl String.Chars, for: Monkeylang.AST.Integer do
  def to_string(node = %Monkeylang.AST.Integer{}) do
    node.token.literal
  end
end

defmodule Monkeylang.AST.PrefixExpression do
  @enforce_keys [:token, :operator, :right]
  defstruct [:token, :operator, :right]

  @type t :: %__MODULE__{
          token: Monkeylang.Token.t(),
          operator: String.t(),
          right: term()
        }
end

defimpl String.Chars, for: Monkeylang.AST.PrefixExpression do
  def to_string(node = %Monkeylang.AST.PrefixExpression{}) do
    "(#{node.token.literal}#{node.right})"
  end
end

defmodule Monkeylang.AST.InfixExpression do
  @enforce_keys [:token, :operator, :left, :right]
  defstruct [:token, :operator, :left, :right]

  @type t :: %__MODULE__{
          token: Monkeylang.Token.t(),
          operator: String.t(),
          left: term(),
          right: term()
        }
end

defimpl String.Chars, for: Monkeylang.AST.InfixExpression do
  def to_string(node = %Monkeylang.AST.InfixExpression{}) do
    "(#{node.left}#{node.token.literal}#{node.right})"
  end
end
