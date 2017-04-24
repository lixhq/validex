defmodule Validex do
  :wa
  @moduledoc """
  Documentation for Validex.
  """

  @doc """
  Verify data against schema returning both valid and invalid validations

  ## Examples

      iex> Validex.verify(%{ name: 5 }, [name: :string])
      [{:ok, :name, :presence}, {:error, :name, :type, "name should be string but was integer"}]

  """
  def verify(data, schema) when is_map(data) and is_list(schema) do
    validators = Validex.Validator.load_all()
    expanded_schema = Enum.map(schema,
                               fn {attribute, spec} ->
                                 expand_rule(attribute, spec)
                               end)

    Enum.flat_map(expanded_schema,
             fn {attribute, rules} when is_list(rules) ->
               value = Map.get(data, attribute, :__validex_missing__)
               Enum.flat_map(rules, fn {rule_kind, rule_spec} ->
                 validator = find_validator(validators, rule_kind)
                 validator.validate(rule_kind, attribute, rule_spec, value)
               end)

             end
    )
  end

  @doc """
  Verify data against schema returning only invalid validations

  ## Examples

      iex> Validex.errors(%{ name: 5 }, [name: :string])
      [{:error, :name, :type, "name should be string but was integer"}]

  """
  def errors(data, schema) do
    verify(data, schema) |> Enum.filter(&match?({:error, _, _, _}, &1))
  end

  @doc """
  Verify data against schema returning true if no erros were found

  ## Examples

      iex> Validex.valid?(%{ name: "simon" }, [name: :string])
      true

      iex> Validex.valid?(%{ name: 455 }, [name: :string])
      false

  """
  def valid?(data, schema) do
    errors(data, schema) == []
  end

  defp expand_rule(attribute, map) when is_map(map) do
    {attribute, [presence: true, type: :map, nested: map] }
  end

  defp expand_rule(attribute, type) when type in [:string, :integer] do
    {attribute, [presence: true, type: type]}
  end

  defp expand_rule(attribute, rule_set) when is_list(rule_set) do
    rule_set = if Keyword.has_key?(rule_set, :nested) do
      Keyword.put_new(rule_set, :type, Validex.Typer.type_of(Keyword.fetch!(rule_set, :nested)))
    else
      rule_set
    end
    {attribute, Keyword.put_new(rule_set, :presence, true)}
  end

  defp find_validator(validators, rule_kind) do
    case Enum.find(validators, &(&1.rule_kind() == rule_kind)) do
      nil -> Validex.Validators.Unknown
      validator -> validator
    end
  end
end
