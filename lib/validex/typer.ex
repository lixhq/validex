defmodule Validex.Typer do
  def type_of(:__validex_missing__), do: :__validex_missing__
  def type_of(value) when is_map(value), do: :map
  def type_of(value) when is_binary(value), do: :string
  def type_of(value) when is_integer(value), do: :integer
end

