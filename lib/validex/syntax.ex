defmodule Validex.Syntax do

  def optional(rules) do
    Validex.expand_rules(rules) |> Keyword.put(:presence, false)
  end

  def one_of(list) when is_list(list) do
    [one_of: list]
  end

end
