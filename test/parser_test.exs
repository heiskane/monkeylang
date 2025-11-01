defmodule ParserTest do
  use ExUnit.Case
  doctest Monkeylang.Parser

  test "test basic parsing" do
    input = """
      let a = 5;
      let b = 10;
    """
  end
end
