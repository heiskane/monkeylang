defmodule Monkeylang.Environment do
  def new(), do: %{}

  def set(env, name, value) do
    Map.put(env, name, value)
  end

  def get(env, name) do
    Map.get(env, name, %Monkeylang.Error{message: "identifier #{name} not found"})
  end
end
