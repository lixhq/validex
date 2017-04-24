defmodule Validex.Validator do

  @callback validate(attribute :: atom, rule_spec :: keyword, value :: any) :: [{:ok, atom, atom} | {:error, atom, atom, String.t}]

  @callback validate(rule_kind :: atom, attribute :: atom, rule_spec :: keyword, value :: any) :: [{:ok, atom, atom} | {:error, atom, atom, String.t}]

  defmacro __using__(_) do
    quote do
      @behaviour Validex.Validator

      def validate(_, attribute, rule_spec, value) do
        validate(attribute, rule_spec, value)
      end

      defoverridable validate: 4
    end
  end
end
