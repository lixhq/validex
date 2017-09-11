defmodule Validex.Validators.Presence do
  @moduledoc """
  The Presence validator is used for validating the presence of values, the empty string in addition to any value not included in a map is considered absence.

  In addition to validating presence the validator function as a `Validex.RuleExpander` which expands rules to include presence by default if it hasn't been specified otherwise.

  ## Examples

      iex> Validex.Validators.Presence.validate(:presence, :name, true, "", [])
      [{:error, :name, :presence, "name is a required attribute but was absent"}]

      iex> Validex.Validators.Presence.validate(:presence, :name, true, :__validex_missing__, [])
      [{:error, :name, :presence, "name is a required attribute but was absent"}]

      iex> Validex.Validators.Presence.validate(:presence, :name, false, "", [])
      []

      iex> Validex.Validators.Presence.expand([type: :string])
      [presence: :__validex_default_presence, type: :string]

      iex> Validex.Validators.Presence.expand([presence: false, type: :string])
      [presence: false, type: :string]
  """

  use Validex.Validator
  use Validex.RuleExpander
  @blank_values ["", :__validex_missing__]

  def validate(_, _, false, _, _), do: []

  def validate(_, attribute, spec, v, _) when
    v in @blank_values and
    spec in [true, :__validex_default_presence] do
    [{:error, attribute, :presence, "#{attribute} is a required attribute but was absent"}]
  end

  def validate(_, attribute, spec, _, _) when spec in [true, :__validex_default_presence] do
    [{:ok, attribute, :presence}]
  end

  def expand(rule_set) when is_list(rule_set) do
    if Keyword.keyword?(rule_set) do
      Keyword.put_new(rule_set, :presence, :__validex_default_presence)
    else
      []
    end
  end

end
