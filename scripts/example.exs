input = """
  return 1 + 2;

  let five = 5;
  let ten = 10;

  let add = fn(x, y) {
    x + y;
  };

  let result = add(five, ten);

  five != ten;
  five == 5;
  ten == 10;

  let 5 5;

"""

input2 = """
  1 + 2 * -3 / 5;
  -(5 + 5);
  !(true == true);
  (1 + (2 + 3)) * 4;
"""

input3 = """
  if (x < y) { x };
"""

tokens =
  Monkeylang.Lexer.tokenize(input3)
  |> dbg(limit: :infinity)

{statements, errors} =
  Monkeylang.Parser.parse_tokens(tokens)
  |> dbg()

statements
|> Enum.each(&IO.puts/1)
