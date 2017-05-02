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

defmodule Validex.RuleExpanderTest do
  use ExUnit.Case, async: true
  alias Validex.RuleExpanderTest.{OptionalByDefault, Currency}

  setup_all do
    {:ok, [expanders: Agent.get(Validex, &Map.get(&1, :expanders))]}
  end

  setup %{ expanders: expanders } do
    on_exit(fn -> Agent.update(Validex, &Map.put(&1, :expanders, expanders)) end)
  end

  test "can mark presence as false by default" do
    assert [{:error, :name, :presence, _}] = Validex.errors(%{ }, [name: :string])
    :ok = add_expander(OptionalByDefault)
    assert [] = Validex.errors(%{ }, [name: :string])
  end

  test "can expand to a nested spec" do
    assert [{:error, :currency, :__validex__unknown_validator__, _}
    ] = Validex.verify(%{ currency: %{ amount: 5, currency_code: "DKK" }}, [currency: :currency])

    :ok = add_expander(Currency)

    assert [
      {:ok, :currency, :presence},
      {:ok, :currency, :type},
        {:ok, [:currency, :amount], :presence},
        {:ok, [:currency, :amount], :type},
        {:ok, [:currency, :currency_code], :presence},
        {:ok, [:currency, :currency_code], :type}
    ] = Validex.verify(%{ currency: %{ amount: 5, currency_code: "DKK" }}, [currency: :currency])
  end

  defp add_expander(expander) do
    Agent.update(Validex, &Map.update!(&1, :expanders, fn expanders ->
      [expander | expanders]
    end))
  end

end
