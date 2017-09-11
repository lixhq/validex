defmodule Validex.Validators.Nested do
  use Validex.Validator
  use Validex.RuleExpander

  def validate(_, attribute, [rule], list, options) when is_list(list) do

    list
    |> Enum.with_index()
    |> Enum.flat_map(fn {v, index} ->
      Validex.verify(
        %{ attribute => v },
        Keyword.new([{ attribute, rule }]),
        options
      )
      |> Enum.reject(&match?({:ok, _, :presence}, &1))
      |> Enum.map(&adjust_attribute_path(fn
        attr when is_atom(attr) -> [attr, index]
        [_ | attrs] when is_list(attrs) -> [attribute, index] ++ attrs
      end, &1))
    end)

  end

  def validate(_, _, _, value, _) when not is_map(value) do
    []
  end

  def validate(_, attribute, map, value, options) when is_map(value) do
    Validex.verify(value, Keyword.new(map), options)
    |> Enum.map(&adjust_attribute_path(fn
      attr when is_atom(attr) -> [attribute, attr]
      attrs when is_list(attrs) -> [attribute | attrs]
    end, &1))
  end

  defp adjust_attribute_path(attribute_adjuster, res) do
    attr = elem(res, 1)
    Tuple.insert_at(res, 1, attribute_adjuster.(attr)) |> Tuple.delete_at(2)
  end

  def expand(map) when is_map(map) do
    [type: :map, nested: map]
  end

  def expand(rule_set) when is_list(rule_set) do
    if Keyword.keyword?(rule_set) do
      case Keyword.take(rule_set, [:nested]) do
        [nested: nested] when is_map(nested) -> Keyword.put_new(rule_set, :type, :map)
        _ -> rule_set
      end
    else
      [type: :list, nested: rule_set]
    end
  end

end
