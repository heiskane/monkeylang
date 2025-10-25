items = Enum.to_list(1..10_000)

Benchee.run(%{
  "append" => fn ->
    Enum.reduce(items, [], fn i, acc -> acc ++ [i * 2] end)
  end,
  "prepend+reverse" => fn ->
    items
    |> Enum.reduce([], fn i, acc -> [i * 2 | acc] end)
    |> Enum.reverse()
  end
})
