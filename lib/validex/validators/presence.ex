defmodule Validex.Validators.Presence do
  use Validex.Validator

  def validate(_, false, _), do: []

  def validate(attribute, true, :__validex_missing__) do
    [{:error, attribute, :presence, "#{attribute} is a required attribute but was absent"}]
  end

  def validate(attribute, true, _), do: [{:ok, attribute, :presence}]
end

