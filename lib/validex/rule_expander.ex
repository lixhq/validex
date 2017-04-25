defmodule Validex.RuleExpander do
  @moduledoc """
  Schema-expansion is the first step of validating a schema against
  data. RuleExpanders describe which expansions will happen.

  Example:

    defmodule OptionalByDefault do
      use Validex.RuleExpander

      def expand(_, spec) when is_list(spec) do
        Keyword.update(spec, :presence, fn
          :default -> false
          v -> v end)
      end
    end

    defmodule Currency do
      use Validex.RuleExpander

      def expand(_, :user) do
        [nested: %{ amount: :integer, currency_code: :string}]
      end
    end

  """

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

