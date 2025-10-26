# CRUSH.md

## Build, Lint, Test Commands

- **Build:**
  - `mix compile`
- **Run all tests:**
  - `mix test`
- **Run a single test file:**
  - `mix test test/lexer_test.exs`
  - `mix test test/monkeylang_test.exs`
- **Run a specific test by name:**
  - `mix test --only test_name`
- **Run tests with coverage:**
  - `mix test --cover`
- **Lint/Format:**
  - `mix format` (uses `.formatter.exs`)
  - Check format: `mix format --check-formatted`
- **Static analysis:**
  - `mix dialyzer` (if dialyzer set up, depends on :dialyxir)

## Code Style Guidelines

- **Language:** Elixir ~> 1.18, idiomatic Elixir style
- **Formatting:**
  - All code should be formatted with `mix format`
  - 2 spaces indentation; no tabs, trailing whitespace, or extra blank lines
- **Imports/Aliases:**
  - Place `alias`/`import`/`use` after `defmodule`
  - Group and sort alphabetically, limit to used modules
- **Naming:**
  - Modules: `CamelCase` (e.g. `Monkeylang.Lexer`)
  - Functions/variables: `snake_case`
- **Types & Specs:**
  - Use `@spec` for all public functions
  - Use `@type`/`@typedoc` for structs and types when appropriate
- **Docs:**
  - Use `@doc` for all public functions; `@moduledoc` for modules
- **Tests:**
  - Use ExUnit, define tests with `test "desc" do ... end`
  - Prefer descriptive test names (e.g. `test "parse code block"`)
- **Error Handling:**
  - Prefer `{:ok, value}`/`{:error, reason}` tuples
  - Use `raise` only when truly exceptional
- **General:**
  - Pure functions preferred; side effects isolated
  - Avoid global state, stick to explicit data passing

## Misc
- `.crush/` is ignored and reserved for agent configuration.
- No Cursor/Copilot rules present as of this writing.
