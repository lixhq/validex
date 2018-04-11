defmodule Validex.SyntaxTest do
  use ExUnit.Case, async: true

  describe "optional" do
    test "can make type shorthand optional" do
      assert [presence: false, type: :string] = Validex.Syntax.optional(:string)
    end

    test "can make map optional" do
      assert [
               presence: false,
               type: :map,
               nested: %{name: :string}
             ] = Validex.Syntax.optional(%{name: :string})
    end
  end

  describe "one_of" do
    test "can make one_of string" do
      assert [one_of: ["ONE", "TWO"]] = Validex.Syntax.one_of(["ONE", "TWO"])
    end

    test "can make one_of maps" do
      assert [
               one_of: [%{name: :string}, "TWO"]
             ] = Validex.Syntax.one_of([%{name: :string}, "TWO"])
    end
  end
end
