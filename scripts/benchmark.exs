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
    Monkeylang.LexerOld.new(input)
    |> Monkeylang.LexerOld.tokenize()
  end,
  "lexer2" => fn -> Monkeylang.Lexer.tokenize(input) end,
})
