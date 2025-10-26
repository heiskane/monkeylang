defmodule Monkeylang.Token do
  defstruct [:type, :literal]

  @type t :: %__MODULE__{
          type: atom(),
          literal: String.t()
        }

  @spec new(atom(), String.t()) :: t()
  def new(type, literal) do
    %__MODULE__{type: type, literal: literal}
  end
end
