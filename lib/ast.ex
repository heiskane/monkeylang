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

defimpl String.Chars, for: Monkeylang.AST.Return do
  def to_string(node = %Monkeylang.AST.Return{}) do
    "return #{node.value}"
  end
end

defmodule Monkeylang.AST.Boolean do
  @enforce_keys [:token, :value]
  defstruct [:token, :value]

  @type t :: %__MODULE__{
          token: Monkeylang.Token.t(),
          value: boolean()
        }
end

defimpl String.Chars, for: Monkeylang.AST.Boolean do
  def to_string(node = %Monkeylang.AST.Boolean{}) do
    node.token.literal
  end
end

defmodule Monkeylang.AST.Ident do
  @enforce_keys [:token, :value]
  defstruct [:token, :value]

  @type t :: %__MODULE__{
          token: Monkeylang.Token.t(),
          value: String.t()
        }
end

defimpl String.Chars, for: Monkeylang.AST.Ident do
  def to_string(node = %Monkeylang.AST.Ident{}) do
    node.value
  end
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
    "(#{node.left} #{node.token.literal} #{node.right})"
  end
end

defmodule Monkeylang.AST.IfExpression do
  @enforce_keys [:token, :condition, :consequence, :alternative]
  defstruct [:token, :condition, :consequence, :alternative]

  @type t :: %__MODULE__{
          token: Monkeylang.Token.t(),
          condition: term(),
          consequence: term(),
          alternative: term() | nil
        }
end

defimpl String.Chars, for: Monkeylang.AST.IfExpression do
  def to_string(node = %Monkeylang.AST.IfExpression{}) do
    "if #{node.condition} do {#{node.consequence}} else {#{node.alternative || "()"}}"
  end
end

defmodule Monkeylang.AST.BlockStatement do
  @enforce_keys [:token, :statements]
  defstruct [:token, :statements]

  @type t :: %__MODULE__{
          token: Monkeylang.Token.t(),
          statements: list()
        }
end

defimpl String.Chars, for: Monkeylang.AST.BlockStatement do
  def to_string(node = %Monkeylang.AST.BlockStatement{}) do
    Enum.reduce(node.statements, "", &(&2 <> "#{&1}"))
  end
end

defmodule Monkeylang.AST.FunctionLiteral do
  @enforce_keys [:token, :parameters, :body]
  defstruct [:token, :parameters, :body]

  @type t :: %__MODULE__{
          token: Monkeylang.Token.t(),
          parameters: Monkeylang.AST.Ident.t(),
          body: Monkeylang.AST.BlockStatement.t()
        }
end

defimpl String.Chars, for: Monkeylang.AST.FunctionLiteral do
  def to_string(node = %Monkeylang.AST.FunctionLiteral{}) do
    params = Enum.join(node.parameters, ", ")
    "fn(#{params}) { #{node.body} }"
  end
end
