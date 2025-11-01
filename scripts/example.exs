input = """
  let five = 5;
  let ten = 10;

  let add = fn(x, y) {
    x + y;
  };

  let result = add(five, ten);

  five != ten;
  five == 5;
  ten == 10;
"""

tokens = Monkeylang.Lexer.tokenize(input)
# |> dbg(limit: :infinity)

Monkeylang.Parser.parse_tokens(tokens)
|> dbg()
