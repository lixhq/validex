defmodule Validex.Validators.Type do
  @moduledoc """
  The Type validator is used for validating types of values.

  ## Examples

      iex> Validex.Validators.Type.validate(:name, :string, "Simon")
      [{:ok, :name, :type}]

      iex> Validex.Validators.Type.validate(:name, :string, 5)
      [{:error, :name, :type, "name should be string but was integer"}]
  """
  use Validex.Validator
  use Validex.RuleExpander

  defmodule Typer do
    types = ~w[function nil integer list map float atom tuple pid port reference]

    def valid_type?(:__validex_missing__, _), do: true
    def valid_type?(v, :string), do: String.valid?(v)
    def valid_type?(v, :number) when is_float(v) or is_integer(v), do: true
    def valid_type?(%{ __struct__: module}, module), do: true
    def valid_type?(_, :any), do: true
    for type <- types do
      def valid_type?(v, unquote(:"#{type}")) when unquote(:"is_#{type}")(v), do: true
    end
    def valid_type?(_, _), do: false

    def type_of(%{ __struct__: module}), do: module
    for type <- types do
      def type_of(v) when unquote(:"is_#{type}")(v), do: unquote(:"#{type}")
    end
    def type_of(v) when is_bitstring(v) do
      cond do
        String.valid?(v) -> :string
        is_binary(v) -> :binary
        is_bitstring(v) -> :bitstring
      end
    end
    def type_of(_), do: :any
  end

  def validate(_, _, :__validex_missing__), do: []

  def validate(attribute, expected_type, value) do
    if Typer.valid_type?(value, expected_type) do
      [{:ok, attribute, :type}]
    else
      [{:error, attribute, :type,
        "#{attribute} should be #{expected_type} but was #{Typer.type_of(value)}"}]
    end
  end

  def expand(_, type_shorthand) when type_shorthand in [:string, :integer] do
    [type: type_shorthand]
  end

end

