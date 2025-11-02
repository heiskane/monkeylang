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
  1 + 2 + 3
"""

tokens =
  Monkeylang.Lexer.tokenize(input2)
  |> dbg(limit: :infinity)

{statements, errors} =
  Monkeylang.Parser.parse_tokens(tokens)
  |> dbg()

statements
# |> Enum.each(&IO.puts/1)
