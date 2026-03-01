defmodule Monkeylang.Builtins do
  def len(%Monkeylang.Object{type: :string, value: value}) do
    length = String.length(value)
    %Monkeylang.Object{type: :integer, value: length}
  end

  def len(%Monkeylang.Object{type: type}) do
    %Monkeylang.Error{message: "len not implemented for type #{type}"}
  end
end
