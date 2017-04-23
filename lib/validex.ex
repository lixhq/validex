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
                               fn {attribute, shorthand} ->
                                 expand_rule(attribute, shorthand)
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

  def errors(data, schema) do
    verify(data, schema) |> Enum.filter(&match?({:error, _, _, _}, &1))
  end

  defp get_type(:__validex_missing__), do: :missing
  defp get_type(value) when is_binary(value), do: :string
  defp get_type(value) when is_integer(value), do: :integer

  defp expand_rule(attribute, type) when type in [:string, :integer], do: {attribute, [presence: true, type: type]}

  defp expand_rule(attribute, rule_set) when is_list(rule_set) do
    {attribute, Keyword.put_new(rule_set, :presence, true)}
  end

  defp validate(:presence, attribute, true, _, :__validex_missing__) do
    [{:error, attribute, :presence, "#{attribute} is a required attribute but was missing"}]
  end
  defp validate(:presence, attribute, true, _, _), do: [{:ok, attribute, :presence}]

  defp validate(:type, attribute, _, _, :__validex_missing__) do
    [{:not_applicable, attribute, :type, "type validation for missing #{attribute} is not applicable"}]
  end
  defp validate(:type, attribute, expected_type, actual_type, _) do
    if expected_type != actual_type do
      [{:error, attribute, :type, "#{attribute} should be #{expected_type} but was #{actual_type}"}]
    else
      [{:ok, attribute, :type}]
    end
  end
end
