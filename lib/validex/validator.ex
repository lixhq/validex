defmodule Validex.Validator do
  @type rule_kind :: atom
  @type attribute :: atom
  @type rule_spec :: keyword
  @type value :: any
  @type options :: keyword
  @type attribute_path :: atom | [atom]
  @type error_name :: :atom
  @type error_message :: String.t

  @callback validate(rule_kind, attribute, rule_spec, value, options) :: [
              {:ok, attribute_path, atom} | {:error, attribute_path, error_name, error_message}
            ]

  @callback rule_kind() :: rule_kind

  defmacro __using__(_) do
    quote do
      @behaviour Validex.Validator
      @rule_kind Module.split(__MODULE__)
                 |> List.last()
                 |> String.split(~r{[A-Z]}, include_captures: true, trim: true)
                 |> Enum.chunk(2)
                 |> Enum.map(&(Enum.join(&1) |> String.downcase()))
                 |> Enum.join("_")
                 |> String.to_atom()

      def rule_kind() do
        @rule_kind
      end
    end
  end
end
