defmodule TypeTest do
  use ExUnit.Case, async: true

  @types [:string, :integer, :float, :number, :number, :atom, :list, :map]
  @values ["hello", 5, 5.6, 5, 5.6, :bla, [], %{}]

  @valid_cases Enum.zip(@types, @values) ++ Enum.map(@values, &{:any, &1})

  @invalid_cases Enum.uniq(
    for t <- @types, v <- @values, do: {t, v}
  ) -- @valid_cases


  test "valid cases all checks out" do

    Enum.each(@valid_cases, fn {t, v} ->
      assert [
        {:ok, :prop, :presence}, {:ok, :prop, :type}
      ] = Validex.verify(%{ prop: v }, [prop: [presence: true, type: t]])
    end)

  end

  test "invalid cases all checks out" do
    Enum.each(@invalid_cases, fn {t, v} ->
      assert [
        {:ok, :prop, :presence}, {:error, :prop, :type, _}
      ] = Validex.verify(%{ prop: v }, [prop: [presence: true, type: t]])
    end)
  end
end

