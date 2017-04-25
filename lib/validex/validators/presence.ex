defmodule Validex.Validators.Presence do
  use Validex.Validator
  use Validex.RuleExpander

  def validate(_, false, _), do: []

  def validate(attribute, true, :__validex_missing__) do
    [{:error, attribute, :presence, "#{attribute} is a required attribute but was absent"}]
  end

  def validate(attribute, true, _), do: [{:ok, attribute, :presence}]

  def expand(_, rule_set) when is_list(rule_set) do
    Keyword.put_new(rule_set, :presence, true)
  end

end

