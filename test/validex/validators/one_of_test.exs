defmodule Validex.Validators.OneOfTest do
  use ExUnit.Case, async: true

  describe "one_of" do
    test "can be one of different types" do
      schema = [prop: [one_of: [:string, :integer]]]

      assert [
               {:ok, :prop, :one_of},
               {:ok, :prop, :presence},
               {:ok, :prop, :type}
             ] = Validex.verify(%{prop: "hello"}, schema)

      assert [
               {:ok, :prop, :one_of},
               {:ok, :prop, :presence},
               {:ok, :prop, :type}
             ] = Validex.verify(%{prop: 5}, schema)
    end

    test "errors when it should" do
      schema = [prop: [one_of: [:string, :integer]]]

      assert [
               {:error, :prop, :one_of, _},
               {:ok, :prop, :presence},
               {:error, :prop, :type, _},
               {:error, :prop, :type, _}
             ] = Validex.verify(%{prop: :my_atom}, schema)
    end

    test "can be exact values" do
      schema = [currency_code: [one_of: ["DKK", "GBP"]]]

      assert [
               {:ok, :currency_code, :exact},
               {:ok, :currency_code, :one_of},
               {:ok, :currency_code, :presence}
             ] = Validex.verify(%{currency_code: "DKK"}, schema)
    end

    test "can mix exact and rules" do
      schema = [prop: [one_of: ["DKK", :integer]]]

      assert [
               {:ok, :prop, :exact},
               {:ok, :prop, :one_of},
               {:ok, :prop, :presence}
             ] = Validex.verify(%{prop: "DKK"}, schema)

      assert [
               {:ok, :prop, :one_of},
               {:ok, :prop, :presence},
               {:ok, :prop, :type}
             ] = Validex.verify(%{prop: :rand.uniform(1000)}, schema)
    end

    test "works with nested" do
      schema = [prop: [one_of: ["DKK", %{name: :string}]]]

      assert [
               {:ok, :prop, :one_of},
               {:ok, :prop, :presence},
               {:ok, :prop, :type},
               {:ok, [:prop, :name], :presence},
               {:ok, [:prop, :name], :type}
             ] = Validex.verify(%{prop: %{name: "Simon"}}, schema)

      schema = [prop: [one_of: [%{name: [exact: :uni_login], id: :string}]]]

      assert [
               {:ok, :prop, :one_of},
               {:ok, :prop, :presence},
               {:ok, :prop, :type},
               {:ok, [:prop, :id], :presence},
               {:ok, [:prop, :id], :type},
               {:ok, [:prop, :name], :exact},
               {:ok, [:prop, :name], :presence}
             ] = Validex.verify(%{prop: %{name: :uni_login, id: "Simon"}}, schema)
    end

    test "works with presence false" do
      schema = [
        prop: [one_of: ["DKK", %{name: :string}]],
        prop2: [one_of: ["DKK", %{name: :string}], presence: false],
      ]

      assert [
               {:ok, :prop, :one_of},
               {:ok, :prop, :presence},
               {:ok, :prop, :type},
               {:ok, [:prop, :name], :presence},
               {:ok, [:prop, :name], :type}
             ] = Validex.verify(%{prop: %{name: "Simon"}}, schema)

      assert [
               {:error, :prop, :presence, _},
               {:ok, :prop2, :one_of},
               {:ok, :prop2, :presence},
               {:ok, :prop2, :type},
               {:ok, [:prop2, :name], :presence},
               {:ok, [:prop2, :name], :type}
             ] = Validex.verify(%{prop2: %{name: "Simon"}}, schema)
    end
  end
end
