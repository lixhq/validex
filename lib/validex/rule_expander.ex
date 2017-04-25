defmodule Validex.RuleExpander do

  @callback expand(attribute :: atom, shorthand :: atom) :: keyword

  defmacro __using__(_opts) do
    quote do
      @behaviour Validex.RuleExpander
      @before_compile Validex.RuleExpander
    end
  end

  def load_all() do
    Validex.PluginLoader.load_all(__MODULE__)
  end

  defmacro __before_compile__(_env) do
    quote do
      def expand(_,rule_set), do: rule_set
    end
  end
end

