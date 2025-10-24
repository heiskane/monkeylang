defmodule Monkeylang.Token do
  defstruct [:type, :literal]

  def new(type, literal) do
    %__MODULE__{type: type, literal: literal}
  end
end
