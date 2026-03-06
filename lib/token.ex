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
    :notequals,
    :equals,
    :assign,
    :int,
    :ident,
    :let,
    :function,
    :bang,
    :minus,
    :slash,
    :asterisk,
    :lt,
    :gt,
    :true,
    :false,
    :if,
    :else,
    :return,
    :string,
    :lbracket,
    :rbracket
  ]

  @precedences %{
    :equals => 1,
    :notequals => 1,
    :lt => 2,
    :gt => 2,
    :plus => 3,
    :minus => 3,
    :slash => 4,
    :asterisk => 4,
    :prefix => 5,
    :lparen => 6,
    :lbracket => 7
  }

  # This is not enforced anyway so keep it an atom
  @type token_type :: atom()
  @type t :: %__MODULE__{
          type: token_type(),
          literal: String.t()
        }

  @spec new(token_type(), String.t()) :: t()
  def new(type, literal) when type in @token_types do
    %__MODULE__{
      type: type,
      literal: literal
    }
  end

  def new(type, _literal) do
    raise ArgumentError,
          "Invalid token type: #{inspect(type)}. Allowed types: #{@token_types |> Enum.join(", ")}"
  end

  def get_precedence(%__MODULE__{type: type}),
    do: Map.get(@precedences, type, 0)
end
