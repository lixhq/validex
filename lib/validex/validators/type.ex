defmodule Validex.Validators.Type do
  use Validex.Validator

  def validate(_, _, :__validex_missing__), do: []

  def validate(attribute, expected_type, value) do
    actual_type = Validex.Typer.type_of(value)
    if expected_type != actual_type do
      [{:error, attribute, :type, "#{attribute} should be #{expected_type} but was #{actual_type}"}]
    else
      [{:ok, attribute, :type}]
    end
  end
end
