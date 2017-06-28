defmodule Validex.RuleExpander do
  @moduledoc """
  Schema-expansion is the first step of validating a schema against
  data. RuleExpanders describe which expansions will happen.

  Example:

  The following rule-expander makes attributes optional by default

      defmodule OptionalByDefault do
        use Validex.RuleExpander

        def expand(spec) when is_list(spec) do
          Keyword.update(spec, :presence, fn
            :__validex_default_presence -> false
            v -> v end)
        end
      end

  The following rule-expander creates a :currency shorthand for defining
  a schema with an amount of type integer and currency_code of type string

      defmodule Currency do
        use Validex.RuleExpander

        def expand(:currency) do
          [nested: %{ amount: :integer, currency_code: :string}]
        end
      end

  """

  @callback expand(rule_set :: any) :: keyword

  defmacro __using__(_opts) do
    quote do
      @behaviour Validex.RuleExpander
      @before_compile Validex.RuleExpander
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def expand(rule_set), do: []
    end
  end
end

