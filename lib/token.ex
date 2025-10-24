defmodule Monkeylang.Token do
  defstruct [:type, :literal]

  def new(type, literal) do
    %__MODULE__{type: type, literal: literal}
  end

  def from_string(char) do
    case char do
      "=" -> new(:assign, char)
      "+" -> new(:plus, char)
      "(" -> new(:lparen, char)
      ")" -> new(:rparen, char)
      "{" -> new(:lbrace, char)
      "}" -> new(:rbrace, char)
      "," -> new(:comma, char)
      ";" -> new(:semicolon, char)
      "" -> new(:eof, char)
    end
  end
end
