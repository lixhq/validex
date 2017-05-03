defmodule Validex.RuleExpanderTest.OptionalByDefault do
  use Validex.RuleExpander
  @moduledoc false

  def expand(spec) when is_list(spec) do
    if Keyword.keyword?(spec) do
      Keyword.update(spec, :presence, false, fn
        :default -> false
        v -> v end)
    else
      []
    end
  end
end

defmodule Validex.RuleExpanderTest.Currency do
  use Validex.RuleExpander
  @moduledoc false

  def expand(:currency) do
    [nested: %{ amount: :integer, currency_code: :string}]
  end
end
