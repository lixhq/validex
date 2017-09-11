defmodule Validex.Validator do

  @callback validate(rule_kind :: atom, attribute :: atom, rule_spec :: keyword, value :: any, options :: keyword) :: [{:ok, atom | [atom], atom} | {:error, atom | [atom], atom, String.t}]

  @callback rule_kind() :: atom

  defmacro __using__(_) do
    quote do
      @behaviour Validex.Validator
      @rule_kind Module.split(__MODULE__)
        |> List.last()
        |> String.split(~r{[A-Z]}, include_captures: true, trim: true)
        |> Enum.chunk(2)
        |> Enum.map(&(Enum.join(&1) |> String.downcase()))
        |> Enum.join("_")
        |> String.to_atom

      def rule_kind() do
        @rule_kind
      end
    end
  end

end
