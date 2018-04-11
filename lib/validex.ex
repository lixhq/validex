defmodule Validex do
  @default_expanders [
    Validex.Validators.Exact,
    Validex.Validators.Nested,
    Validex.Validators.Presence,
    Validex.Validators.Type
  ]
  @default_validators [
    Validex.Validators.Exact,
    Validex.Validators.Nested,
    Validex.Validators.OneOf,
    Validex.Validators.Presence,
    Validex.Validators.Type,
    Validex.Validators.Unknown
  ]

  @moduledoc """
  Validex is a library for doing data validation in Elixir. Using a schema you
  specify what rules each attribute in your schema should be validated against.
  Each rule is implemented as a combination of `Validex.Validator` validators.

  Before a schema is used for verification it is expanded, the purpose of the
  expansion is twofold. First it translate syntactic shorthands into a proper
  schema acceptable by `Validex.Validator` and secondly it allows for adding
  default unspecified rules to each attribute in the schema. Expansion happens
  using modules that implements the `Validex.RuleExpander` behaviour.

  By default all attributes in a schema are assumed to be required and are thus
  validated against the `Validex.Validators.Presence` validator, this happens because
  `Validex.Validators.Presence` also expands each spec to include a presence
  check.
  """

  @doc """
  Verify data against schema returning both valid and invalid validations.

  ## Examples

      iex> Validex.verify(%{ name: 5 }, [name: :string])
      [{:ok, :name, :presence}, {:error, :name, :type, "name should be string but was integer"}]

  """
  def verify(data, schema, config \\ []) when is_map(data) and is_list(schema) do
    {validators, expanders} = get_plugins(config)

    expanded_schema =
      Enum.map(schema, fn {attribute, spec} ->
        {attribute, expand_rules(expanders, spec)}
      end)

    result =
      Enum.flat_map(expanded_schema, fn
        {attribute, rules} when is_list(rules) ->
          value = Map.get(data, attribute, :__validex_missing__)

          Enum.flat_map(rules, fn {rule_kind, rule_spec} ->
            validator = find_validator(validators, rule_kind)
            validator.validate(rule_kind, attribute, rule_spec, value, config)
          end)

        {attribute, shorthand} when is_atom(shorthand) ->
          value = Map.get(data, attribute, :__validex_missing__)
          Validex.Validators.Unknown.validate(shorthand, attribute, shorthand, value, config)
      end)

    result =
      if Keyword.get(config, :strict, false) do
        schema_keys = Keyword.keys(expanded_schema) |> MapSet.new()

        Map.keys(data)
        |> MapSet.new()
        |> MapSet.difference(schema_keys)
        |> MapSet.to_list()
        |> Enum.map(&{:error, &1, :strict, "#{&1} is an unexpected attribute"})
        |> Enum.concat(result)
      else
        result
      end

    result
    |> Enum.uniq()
    |> Enum.sort(fn a, b ->
      ak = elem(a, 1)
      bk = elem(b, 1)

      case {ak, bk} do
        {ak, bk} when is_atom(ak) and is_list(bk) -> {[ak], elem(a, 2)} <= {bk, elem(b, 2)}
        {ak, bk} when is_list(ak) and is_atom(bk) -> {ak, elem(a, 2)} <= {[bk], elem(b, 2)}
        {ak, bk} -> {ak, elem(a, 2)} <= {bk, elem(b, 2)}
      end
    end)
  end

  @doc """
  Verify data against schema returning only invalid validations

  ## Examples

      iex> Validex.errors(%{ name: 5 }, [name: :string])
      [{:error, :name, :type, "name should be string but was integer"}]

  """
  def errors(data, schema, config \\ []) when is_map(data) and is_list(schema) do
    Validex.verify(data, schema, config) |> Enum.filter(&match?({:error, _, _, _}, &1))
  end

  @doc """
  Verify data against schema returning false if any errors were found, otherwise it
  returns true.

  ## Examples

      iex> Validex.valid?(%{ name: "simon" }, [name: :string])
      true

      iex> Validex.valid?(%{ name: 455 }, [name: :string])
      false

  """
  def valid?(data, schema, config \\ []) do
    errors(data, schema, config) == []
  end

  defp find_validator(validators, rule_kind) do
    case Enum.find(validators, &(&1.rule_kind() == rule_kind)) do
      nil -> Validex.Validators.Unknown
      validator -> validator
    end
  end

  @doc """
  Expands a rule using modules implementing the `Validex.RuleExpander`
  behaviour. Optionally you can specify expanders to use in addition
  to the built in expanders. Expansion happens

  ## Examples

      iex> Validex.expand(:string)
      [presence: :__validex_default_presence, type: :string]

      iex> Validex.expand(%{ name: :string })
      [presence: :__validex_default_presence, type: :map, nested: %{ name: :string }]
  """
  def expand(spec, additional_expanders \\ []) do
    expand_rules(@default_expanders ++ additional_expanders, spec)
  end

  defp expand_rules(expanders, spec) do
    rules =
      expanders
      |> Enum.map(& &1.expand(spec))
      |> Enum.filter(&(&1 != spec))
      |> Enum.concat()
      |> Enum.uniq()

    if rules == [] do
      spec
    else
      expand_rules(expanders, rules)
    end
  end

  def get_plugins(config) do
    expanders = Keyword.get(config, :expanders, []) ++ @default_expanders
    validators = Keyword.get(config, :validators, []) ++ @default_validators
    {validators, expanders}
  end
end
