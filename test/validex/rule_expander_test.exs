defmodule Validex.RuleExpanderTest do
  use ExUnit.Case, async: true
  alias Validex.RuleExpanderTest.{OptionalByDefault, Currency}

  test "can mark presence as false by default" do
    assert [{:error, :name, :presence, _}] = Validex.errors(%{}, name: :string)
    assert [] = Validex.errors(%{}, [name: :string], expanders: [OptionalByDefault])
  end

  test "can expand to a nested spec" do
    assert [{:error, :currency, :__validex__unknown_validator__, _}] =
             Validex.verify(%{currency: %{amount: 5, currency_code: "DKK"}}, currency: :currency)

    assert [
             {:ok, :currency, :presence},
             {:ok, :currency, :type},
             {:ok, [:currency, :amount], :presence},
             {:ok, [:currency, :amount], :type},
             {:ok, [:currency, :currency_code], :presence},
             {:ok, [:currency, :currency_code], :type}
           ] =
             Validex.verify(
               %{currency: %{amount: 5, currency_code: "DKK"}},
               [currency: :currency],
               expanders: [Currency]
             )
  end
end
