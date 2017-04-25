defmodule OptionalByDefault do
  use Validex.RuleExpander
  @moduledoc false

  def expand(_, spec) when is_list(spec) do
    Keyword.update(spec, :presence, false, fn
      :default -> false
      v -> v end)
  end
end

defmodule Currency do
  use Validex.RuleExpander
  @moduledoc false

  def expand(_, :currency) do
    [nested: %{ amount: :integer, currency_code: :string}]
  end
end

defmodule RuleExpanderTest do
  use ExUnit.Case

  test "can mark presence as false by default" do
    assert [{:error, :name, :presence, _}] = Validex.errors(%{ }, [name: :string])
    Agent.update(Validex, &Map.update!(&1, :expanders, fn expanders -> [OptionalByDefault | expanders] end))
    assert [] = Validex.errors(%{ }, [name: :string])
  end

  test "can expand to a nested spec" do

    Agent.update(Validex, &Map.update!(&1, :expanders, fn expanders -> [Currency | expanders] -- [OptionalByDefault] end))
    assert [
      {:ok, :currency, :presence},
      {:ok, :currency, :type},
        {:ok, [:currency, :amount], :presence},
        {:ok, [:currency, :amount], :type},
        {:ok, [:currency, :currency_code], :presence},
        {:ok, [:currency, :currency_code], :type}
    ] = Validex.verify(%{ currency: %{ amount: 5, currency_code: "DKK" }}, [currency: :currency])
  end

end
