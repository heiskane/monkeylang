defmodule Mix.Tasks.Repl do
  use Mix.Task

  @shortdoc "Runs Mokeylang REPL"

  @impl true
  def run(_args) do
      Mix.shell().info([:cyan, "===> Starting Mokeylang REPL"])
      Monkeylang.Repl.start()
  end
end
