input = """
  let five = 5;
  let ten = 10;

  let add = fn(x, y) {
    x + y;
  };

  let result = add(five, ten);
"""

Benchee.run(%{
  "lexer1" => fn ->
    Monkeylang.Lexer.new(input)
    |> Monkeylang.Lexer.tokenize()
  end,
  "lexer2" => fn -> Monkeylang.Lexer2.tokenize(input) end,
})
