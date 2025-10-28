defmodule Mix.Tasks.Check do
  use Mix.Task

  @shortdoc "Runs dialyzer and tests"

  @moduledoc """
  Runs dialyzer (if available) and test suite in sequence.
  Fails if any check fails.
  """

  @impl true
  def run(_args) do
    if dialyzer_installed?() do
      Mix.shell().info([:cyan, "===> Running Dialyzer..."])

      case Mix.Task.run("dialyzer", []) do
        :ok -> :ok
        _ -> raise "Dialyzer failed"
      end
    else
      Mix.shell().info([:yellow, "Dialyzer is not in your mix.exs. Skipping Dialyzer step."])
    end

    Mix.shell().info([:cyan, "===> Running tests..."])

    {_output, exit_status} =
      System.cmd("mix", ["test"], env: [{"MIX_ENV", "test"}], into: IO.stream(:stdio, :line))

    if exit_status != 0, do: raise("Tests failed")
  end

  defp dialyzer_installed? do
    deps = Mix.Project.config()[:deps] || []

    Enum.any?(deps, fn
      {:dialyxir, _, _} -> true
      _ -> false
    end)
  end
end
