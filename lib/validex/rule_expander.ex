defmodule Validex.RuleExpander do

  @callback expand(attribute :: atom, rule_set :: any) :: keyword

  defmacro __using__(_opts) do
    quote do
      @behaviour Validex.RuleExpander
      @before_compile Validex.RuleExpander
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def expand(_,rule_set), do: rule_set
    end
  end
end

