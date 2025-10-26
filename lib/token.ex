defmodule Monkeylang.Token do
  defstruct [:type, :literal]

  @type token_type ::
          :illegal
          | :eof
          | :plus
          | :lparen
          | :rparen
          | :lbrace
          | :rbrace
          | :comma
          | :semicolon
          | :unequals
          | :equals
          | :assign
          | :int
          | :ident
          | :not  # not sure if this will stay

  @type t :: %__MODULE__{
          type: token_type(),
          literal: String.t()
        }

  @spec new(token_type(), String.t()) :: t()
  def new(type, literal) do
    %__MODULE__{type: type, literal: literal}
  end
end
