defmodule Validex.Validators.NestedTest do
  use ExUnit.Case, async: true

  doctest Validex.Validators.Nested

  describe "nested" do
    test "can handle deep maps" do
      assert Validex.valid?(
               %{my: %{complex: %{structure: "nisse"}}},
               my: %{complex: %{structure: :string}}
             )

      refute Validex.valid?(
               %{my: %{complex: %{structure: 5}}},
               my: %{complex: %{structure: :string}}
             )
    end

    test "can handle lists" do
      assert [
               {:ok, :my, :presence},
               {:ok, :my, :type},
               {:ok, [:my, 0], :type},
               {:ok, [:my, 1], :type}
             ] = Validex.verify(%{my: ["str", "ing"]}, my: [:string])

      assert [
               {:ok, :my, :presence},
               {:ok, :my, :type},
               {:ok, [:my, 0], :type},
               {:error, [:my, 1], :type, _}
             ] = Validex.verify(%{my: ["str", 1]}, my: [:string])
    end

    test "can handle nested lists" do
      assert [
               {:ok, :my, :presence},
               {:ok, :my, :type},
               {:ok, [:my, 0], :type},
               {:ok, [:my, 0, :complex], :type},
               {:ok, [:my, 0, :complex, :structure], :type},
               {:ok, [:my, 1], :type},
               {:ok, [:my, 1, :complex], :type},
               {:ok, [:my, 1, :complex, :structure], :type}
             ] =
               Validex.verify(
                 %{
                   my: [
                     %{complex: %{structure: "hello"}},
                     %{complex: %{structure: "hello2"}}
                   ]
                 },
                 my: [%{complex: %{structure: :string}}]
               )

      assert [
               {:ok, :my, :presence},
               {:ok, :my, :type},
               {:ok, [:my, 0], :type},
               {:ok, [:my, 0, :complex], :type},
               {:error, [:my, 0, :complex, :structure], :presence, _},
               {:ok, [:my, 1], :type},
               {:ok, [:my, 1, :complex], :type},
               {:error, [:my, 1, :complex, :structure], :type, _},
               {:error, [:my, 2], :type, _}
             ] =
               Validex.verify(
                 %{
                   my: [
                     %{complex: %{}},
                     %{complex: %{structure: 5}},
                     "hello"
                   ]
                 },
                 my: [%{complex: %{structure: :string}}]
               )
    end
  end
end
