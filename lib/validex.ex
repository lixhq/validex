defmodule Validex do
  @default_expanders [Validex.Validators.Exact, Validex.Validators.Nested, Validex.Validators.Presence, Validex.Validators.Type]
  @default_validators [Validex.Validators.Exact, Validex.Validators.Nested, Validex.Validators.OneOf, Validex.Validators.Presence, Validex.Validators.Type, Validex.Validators.Unknown]

  @moduledoc """
  Documentation for Validex.
  """

  @doc """
  Verify data against schema returning both valid and invalid validations.

  ## Examples

      iex> Validex.verify(%{ name: 5 }, [name: :string])
      [{:ok, :name, :presence}, {:error, :name, :type, "name should be string but was integer"}]

  """
  def verify(data, schema, config \\ []) when is_map(data) and is_list(schema) do
    {validators, expanders} = get_plugins(config)

    expanded_schema = Enum.map(schema, fn {attribute, spec} ->
      {attribute, expand_rules(expanders, spec)}
    end)

    result = Enum.flat_map(expanded_schema, fn {attribute, rules} when is_list(rules) ->
      value = Map.get(data, attribute, :__validex_missing__)
      Enum.flat_map(rules, fn {rule_kind, rule_spec} ->
        validator = find_validator(validators, rule_kind)
        validator.validate(rule_kind, attribute, rule_spec, value)
      end)
      {attribute, shorthand} when is_atom(shorthand) ->
        value = Map.get(data, attribute, :__validex_missing__)
        Validex.Validators.Unknown.validate(shorthand, attribute, shorthand, value)
    end)

    result |> Enum.uniq() |> Enum.sort(
      fn a, b ->
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
  Verify data against schema returning true if no erros were found

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

  def expand_rules(spec) do
    expand_rules(@default_expanders, spec)
  end

  defp expand_rules(expanders, spec) do
    rules = expanders
            |> Enum.map(&(&1.expand(spec)))
            |> Enum.filter(&(&1 != spec))
            |> Enum.concat |> Enum.uniq

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

