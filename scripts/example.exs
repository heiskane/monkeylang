input = """
  let five = 5;
  let ten = 10;

  let add = fn(x, y) {
    x + y;
  };

  let result = add(five, ten);
"""

tokens =
  Monkeylang.Lexer.new(input)
  |> Monkeylang.Lexer.tokenize()

dbg(tokens)
