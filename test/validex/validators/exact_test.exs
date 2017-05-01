defmodule Validex.Validators.ExactTest do
  use ExUnit.Case, async: true

  doctest Validex.Validators.Exact

  describe "exact" do
    test "works with strings" do
      assert [
        {:ok, :currency_code, :exact},
        {:ok, :currency_code, :presence}
      ] = Validex.verify(%{ currency_code: "DKK" }, [currency_code: [exact: "DKK"]])
    end

    test "works with numbers" do
      assert [
        {:ok, :prop, :exact},
        {:ok, :prop, :presence}
      ] = Validex.verify(%{ prop: 5 }, [prop: [exact: 5]])

      assert [
        {:ok, :prop, :exact},
        {:ok, :prop, :presence}
      ] = Validex.verify(%{ prop: 5.6 }, [prop: [exact: 5.6]])
    end

    test "errors if incorrect" do
      assert [
        {:error, :prop, :exact, "expected 5 but got hello"},
        {:ok, :prop, :presence}
      ] = Validex.verify(%{ prop: "hello" }, [prop: [exact: 5]])
    end

    test "can use shorthand for strings and integers" do
      assert [
        {:ok, :prop, :exact},
        {:ok, :prop, :presence}
      ] = Validex.verify(%{ prop: "hello" }, [prop: "hello"])

      assert [
        {:ok, :prop, :exact},
        {:ok, :prop, :presence}
      ] = Validex.verify(%{ prop: 5 }, [prop: 5])

    end

    test "doesn't report if missing" do
      assert [
        {:error, :prop, :presence, _},
      ] = Validex.verify(%{ }, [prop: [exact: 5]])
    end
  end
end
