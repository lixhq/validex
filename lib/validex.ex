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
    expanded_schema = Enum.map(schema, fn {attribute, spec} ->
      {attribute, expand_rules(expanders(), attribute, spec)}
    end)

    Enum.flat_map(expanded_schema, fn {attribute, rules} when is_list(rules) ->
      value = Map.get(data, attribute, :__validex_missing__)
      Enum.flat_map(rules, fn {rule_kind, rule_spec} ->
        validator = find_validator(validators(), rule_kind)
        validator.validate(rule_kind, attribute, rule_spec, value)
      end)
    end) |> Enum.sort(
      fn a, b ->
        ak = elem(a, 1)
        bk = elem(b, 1)

        case {ak, bk} do
          {ak, bk} when is_atom(ak) and is_list(bk) -> [ak] <= bk
          {ak, bk} when is_list(ak) and is_atom(bk) -> ak <= [bk]
          {ak, bk} -> ak <= bk
        end

      end) |> Enum.uniq()
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

  defp find_validator(validators, rule_kind) do
    case Enum.find(validators, &(&1.rule_kind() == rule_kind)) do
      nil -> Validex.Validators.Unknown
      validator -> validator
    end
  end

  defp expand_rules(expanders, attribute, spec) do
    rules = Enum.flat_map(expanders, fn expander ->
      expanded_rule_set = expander.expand(attribute, spec)
      if expanded_rule_set != spec do
        expanded_rule_set
      else
        []
      end
    end)
    if rules == [] do
      spec
    else
      expand_rules(expanders, attribute, rules)
    end
  end

  defp validators() do
    load_plugins()
    Agent.get(__MODULE__, &Map.fetch!(&1, :validators)) |> Enum.uniq
  end

  defp expanders() do
    load_plugins()
    Agent.get(__MODULE__, &Map.fetch!(&1, :expanders)) |> Enum.uniq
  end

  defp load_plugins() do
    unless Process.whereis(__MODULE__) do
      Agent.start(fn -> Map.new() end, name: __MODULE__)
      Agent.update(__MODULE__, &Map.merge(&1, %{
        expanders: Validex.PluginLoader.load_all(Validex.RuleExpander),
        validators: Validex.PluginLoader.load_all(Validex.Validator)
      }))
    end
  end

end

