defmodule Monkeylang.Environment do
  def new(),
    do: %{
      "len" => %Monkeylang.Builtin{
        function: fn
          [%Monkeylang.Object{type: :string, value: value}] ->
            length = String.length(value)
            %Monkeylang.Object{type: :integer, value: length}

          [value] ->
            dbg(value)
            %Monkeylang.Error{message: "len function not implemented for #{value.type}"}
        end
      }
    }

  def set(env, name, value),
    do: Map.put(env, name, value)

  def get(env, name),
    do: Map.get(env, name, %Monkeylang.Error{message: "identifier #{name} not found"})
end
