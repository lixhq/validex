defmodule Validex.Validators.Exact do
  use Validex.Validator
  use Validex.RuleExpander

  def validate(_, _, :__validex_missing__) do
    []
  end

  def validate(attribute, expected_value, actual_value) when is_binary(expected_value) or is_number(expected_value) do
    if expected_value == actual_value do
      [{:ok, attribute, :exact}]
    else
      [{:error, attribute, :exact, "expected #{expected_value} but got #{actual_value}"}]
    end
  end

  def expand(_, exact_value) when is_binary(exact_value) or is_number(exact_value) do
    [exact: exact_value]
  end
end

