defmodule ValidexTest do
  use ExUnit.Case
  doctest Validex

  test "string type is verified" do
    schema = [name: [type: :string]]
    data = %{ name: 455 }

    assert [{:error, :name, :type, "name should be string but was integer"}] 
           = Validex.errors(data, schema)
  end

  test "integer type is verified" do
    schema = [age: [type: :integer]]
    data = %{ age: "15" }

    assert [{:error, :age, :type, "age should be integer but was string"}]
           = Validex.errors(data, schema)
  end

  test "shorthand form works" do
    schema = [age: :integer]
    data = %{age: 15}
    assert [{:ok, :age, :presence}, {:ok, :age, :type}] = Validex.verify(data, schema)
  end

  test "can mix shorthand and fullform" do
    schema = [age: :integer, name: [type: :string]]
    data = %{age: 15, name: 455}
    assert [{:ok, :age, :presence}, {:ok, :age, :type}, {:ok, :name, :presence}, {:error, :name, :type, _}] = Validex.verify(data, schema)
  end

  test "can mix shorthand and fullform when one is missing" do
    schema = [age: :integer, name: [type: :string]]
    data = %{age: 15}
    assert [{:ok, :age, :presence}, {:ok, :age, :type}, {:error, :name, :presence, _}, {:not_applicable, :name, :type, _}] = Validex.verify(data, schema)
  end

  test "multiple properties are all verified" do
    schema = [name: :string, age: :integer]
    data = %{ age: "15", name: 755 }
    assert [{:error, :name, :type, "name should be string but was integer"},
            {:error, :age, :type, "age should be integer but was string"}]
           = Validex.errors(data, schema)

  end

  test "properties are required by default" do
    schema = [age: :integer]
    data = %{}
    assert [{:error, :age, :presence, "age is a required attribute but was missing"}]
           = Validex.errors(data, schema)
  end

end
