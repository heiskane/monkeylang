defmodule Monkeylang.Builtins do
  def len([%Monkeylang.Object{type: :string, value: value}]) do
    length = String.length(value)
    %Monkeylang.Object{type: :integer, value: length}
  end
end
