defmodule Validex.Validators.Nested do
  use Validex.Validator

  def validate(_, _, :__validex_missing__), do: []

  def validate(_, _, value) when not is_map(value) do
    []
  end

  def validate(attribute, map, value) when is_map(value) do
    Validex.verify(value, Keyword.new(map))
    |> Enum.map(fn
      {:ok, nested_attribute, validator} when is_atom(nested_attribute)->
        {:ok, [attribute, nested_attribute], validator}
      {:ok, attribute_path, validator} when is_list(attribute_path) ->
        {:ok, [attribute | attribute_path], validator}
      {response, nested_attribute, validator, msg} when is_atom(nested_attribute) ->
        {response, [attribute, nested_attribute], validator, msg}
      {response, attribute_path, validator, msg} when is_list(attribute_path) ->
        {response, [attribute | attribute_path], validator, msg}
    end)
  end
end
