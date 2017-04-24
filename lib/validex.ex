defmodule Validex do
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
    expanded_schema = Enum.map(schema,
                               fn {attribute, spec} ->
                                 expand_rule(attribute, spec)
                               end)

    Enum.flat_map(expanded_schema,
             fn {attribute, rules} when is_list(rules) ->
               value = Map.get(data, attribute, :__validex_missing__)
               actual_type = get_type(value)
               Enum.flat_map(rules, fn {rule_kind, rule_spec} ->
                 validate(rule_kind, attribute, rule_spec, actual_type, value)
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

  defp get_type(:__validex_missing__), do: :__validex_missing__
  defp get_type(value) when is_map(value), do: :map
  defp get_type(value) when is_binary(value), do: :string
  defp get_type(value) when is_integer(value), do: :integer

  defp expand_rule(attribute, map) when is_map(map) do
    {attribute, [presence: true, type: :map, nested: map] }
  end

  defp expand_rule(attribute, type) when type in [:string, :integer] do
    {attribute, [presence: true, type: type]}
  end

  defp expand_rule(attribute, rule_set) when is_list(rule_set) do
    rule_set = if Keyword.has_key?(rule_set, :nested) do
      Keyword.put_new(rule_set, :type, get_type(Keyword.fetch!(rule_set, :nested)))
    else
      rule_set
    end
    {attribute, Keyword.put_new(rule_set, :presence, true)}
  end

  defp validate(:presence, _, false, _, _), do: []

  defp validate(:presence, attribute, true, _, :__validex_missing__) do
    [{:error, attribute, :presence, "#{attribute} is a required attribute but was absent"}]
  end

  defp validate(:presence, attribute, true, _, _), do: [{:ok, attribute, :presence}]

  defp validate(:nested, _, _, _, :__validex_missing__), do: []

  defp validate(:nested, _, _, actual_type, _) when actual_type != :map do
    []
  end

  defp validate(:nested, attribute, map, :map, value) do
    Validex.verify(value, Keyword.new(map))
    |> Enum.map(fn
      {:ok, nested_attribute, validator} when is_atom(nested_attribute)->
        {:ok, [attribute, nested_attribute], validator}
      {:ok, attribute_path, validator} when is_list(attribute_path) ->
        {:ok, [attribute | attribute_path], validator}
      {response, nested_attribute, validator, msg} when is_atom(nested_attribute) ->
        {response, [attribute, nested_attribute], validator, msg}
      {response, attribute_path, validator, msg} when is_list(attribute_path) ->
        {response, [attribute | attribute_path], validator, msg}
    end)
  end


  defp validate(:type, _, _, _, :__validex_missing__), do: []

  defp validate(:type, attribute, expected_type, actual_type, _) do
    if expected_type != actual_type do
      [{:error, attribute, :type, "#{attribute} should be #{expected_type} but was #{actual_type}"}]
    else
      [{:ok, attribute, :type}]
    end
  end

  defp validate(rule_kind, attribute, rule_spec, _, _) do
    [{:error, attribute, :__validex__unknown_validator__, "#{attribute} has unknown validator #{rule_kind} with spec #{inspect rule_spec}"}]
  end
end
