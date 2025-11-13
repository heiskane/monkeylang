input0 = """
  1 > 1
"""

input1 = """
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
  if (x < y) { x } else { y };
"""

input4 = """
  fn() { return 1 + 1};
"""

input5 = """
  add(1, 2 * 3, add(4 + 5 * 1, -2));
"""

input6 = """
  let potato = fn() { return 1 + 1};
"""

input7 = """
  if (10 > 1) {
    if (10 > 1) {
      return -(10 + 5 * 8);
    } else {
      123;
      456;
    }

    return 1;
  }
"""

input8 = """
  (true + 1) * 5
"""

tokens =
  Monkeylang.Lexer.tokenize(input7)
  |> dbg(limit: :infinity)

{program, errors} =
  Monkeylang.Parser.parse_tokens(tokens)
  |> dbg()

IO.puts(program)

Monkeylang.Evaluator.evaluate(program)
|> dbg()
