defmodule Mix.Tasks.Monke.Repl do
  use Mix.Task

  @shortdoc "Runs Mokeylang REPL"

  @impl true
  def run(_args) do
    monkey_face = ~S( 
              __,__
     .--.  .-"     "-.  .--.
    / .. \/  .-. .-.  \/ .. \
   | |  '|  /   Y   \  |'  | |
   | \   \  \ 0 | 0 /  /   / |
    \ '- ,\.-"""""""-./, -' /
     ''-' /_   ^ ^   _\ '-''
         |  \._   _./  |
         \   \ '~' /   /
          '._ '-=-' _.'
             '-----'
    )

    Mix.shell().info([:cyan, "===> Starting Mokeylang REPL"])
    Mix.shell().info([:green, monkey_face])
    Mix.shell().info([:green, "!! No Monkey Business !!"])
    Monkeylang.Repl.start()
  end
end
