defmodule Validex.Validators.Presence do
  use Validex.Validator
  use Validex.RuleExpander
  @blank_values ["", :__validex_missing__]

  def validate(_, false, _), do: []

  def validate(attribute, spec, v) when
    v in @blank_values and
    spec in [true, :__validex_default__presence] do
    [{:error, attribute, :presence, "#{attribute} is a required attribute but was absent"}]
  end

  def validate(attribute, spec, _) when spec in [true, :__validex_default__presence] do
    [{:ok, attribute, :presence}]
  end

  def expand(_, rule_set) when is_list(rule_set) do
    Keyword.put_new(rule_set, :presence, :__validex_default__presence)
  end

end
