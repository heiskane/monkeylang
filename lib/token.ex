defmodule Monkeylang.Token do
  @enforce_keys [:type, :literal]
  defstruct [:type, :literal]

  @token_types [
    :illegal,
    :eof,
    :plus,
    :lparen,
    :rparen,
    :lbrace,
    :rbrace,
    :comma,
    :semicolon,
    :unequals,
    :equals,
    :assign,
    :int,
    :ident,
    :let,
    :function,
    :not
  ]

  # This is not enforced anyway so keep it an atom
  @type token_type :: atom()

  @type t :: %__MODULE__{
          type: token_type(),
          literal: String.t()
        }

  @spec new(token_type(), String.t()) :: t()
  def new(type, _literal) when type not in @token_types do
    raise ArgumentError,
          "Invalid token type: #{inspect(type)}. Allowed types: #{@token_types |> Enum.join(", ")}"
  end

  def new(type, literal) do
    %__MODULE__{type: type, literal: literal}
  end
end
