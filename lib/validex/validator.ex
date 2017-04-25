defmodule Validex.Validator do

  @callback validate(attribute :: atom, rule_spec :: keyword, value :: any) :: [{:ok, atom | [atom], atom} | {:error, atom | [atom], atom, String.t}]

  @callback validate(rule_kind :: atom, attribute :: atom, rule_spec :: keyword, value :: any) :: [{:ok, atom | [atom], atom} | {:error, atom | [atom], atom, String.t}]

  @callback rule_kind() :: atom

  defmacro __using__(_) do
    quote do
      @behaviour Validex.Validator
      @rule_kind Module.split(__MODULE__) |> List.last() |> String.downcase |> String.to_atom

      def validate(_, attribute, rule_spec, value) do
        validate(attribute, rule_spec, value)
      end

      def rule_kind() do
        @rule_kind
      end

      defoverridable [validate: 4, rule_kind: 0]
    end
  end

end
