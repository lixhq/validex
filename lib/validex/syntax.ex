defmodule Validex.Syntax do
  def optional(rules, additional_expanders \\ []) do
    Validex.expand(rules, additional_expanders) |> Keyword.put(:presence, false)
  end

  def one_of(list) when is_list(list) do
    [one_of: list]
  end
end
