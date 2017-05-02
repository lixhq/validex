defmodule Validex.Validators.Exact do
  @moduledoc """
  The Exact validator is used for validating exact values using simple equality comparison. It works on strings and numbers.

  In addition to validating exact values it also expands literal string or number values into a exact validator rule. This adds a shorthand for specifying exact expetations in the schema.

  ## Examples

      iex> Validex.Validators.Exact.validate(:name, "Simon", "Peter")
      [{:error, :name, :exact, "expected Simon but got Peter"}]

      iex> Validex.Validators.Exact.validate(:my_integer, 5, 5)
      [{:ok, :my_integer, :exact}]
  """

  use Validex.Validator
  use Validex.RuleExpander


  def validate(_, _, :__validex_missing__) do
    []
  end

  def validate(attribute, expected_value, actual_value) when is_binary(expected_value) or is_number(expected_value) do
    if expected_value == actual_value do
      [{:ok, attribute, :exact}]
    else
      printable_value = case actual_value do
        actual_value when is_list(actual_value) or is_map(actual_value) -> inspect(actual_value)
        _ -> actual_value
      end
      [{:error, attribute, :exact, "expected #{expected_value} but got #{printable_value}"}]
    end
  end

  def expand(exact_value) when is_binary(exact_value) or is_number(exact_value) do
    [exact: exact_value]
  end
end

