defmodule Validex.Validators.Presence do
  use Validex.Validator
  use Validex.RuleExpander

  def validate(_, false, _), do: []

  def validate(attribute, spec, :__validex_missing__) when spec in [true, :__validex_default__presence] do
    [{:error, attribute, :presence, "#{attribute} is a required attribute but was absent"}]
  end

  def validate(attribute, spec, _) when spec in [true, :__validex_default__presence] do
    [{:ok, attribute, :presence}]
  end

  def expand(_, rule_set) when is_list(rule_set) do
    Keyword.put_new(rule_set, :presence, :__validex_default__presence)
  end

end
