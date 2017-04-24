defmodule ValidexTest do
  use ExUnit.Case
  doctest Validex

  test "string type is verified" do
    assert [{:error, :name, :type, "name should be string but was integer"}]
           = Validex.errors(%{ name: 455 }, [name: [type: :string]])
  end

  test "integer type is verified" do
    assert [{:error, :age, :type, "age should be integer but was string"}]
           = Validex.errors(%{ age: "15" }, [age: [type: :integer]])
  end

  test "shorthand form works" do
    assert [{:ok, :age, :presence}, {:ok, :age, :type}] = Validex.verify(%{age: 15}, [age: :integer])
  end

  test "can mix shorthand and fullform" do
    assert [
      {:ok, :age, :presence}, {:ok, :age, :type},
      {:ok, :name, :presence}, {:error, :name, :type, _}]
      = Validex.verify(%{age: 15, name: 455}, [age: :integer, name: [type: :string]])
  end

  test "can mix shorthand and fullform when one is absent" do
    assert [
      {:ok, :age, :presence}, {:ok, :age, :type},
      {:error, :name, :presence, _}]
      = Validex.verify(%{age: 15}, [age: :integer, name: [type: :string]])
  end

  test "multiple properties are all verified" do
    assert [{:error, :name, :type, "name should be string but was integer"},
            {:error, :age, :type, "age should be integer but was string"}]
           = Validex.errors(%{ age: "15", name: 755 }, [name: :string, age: :integer])
  end

  test "properties are required by default" do
    assert [{:error, :age, :presence, "age is a required attribute but was absent"}]
           = Validex.errors(%{}, [age: :integer])
  end

  test "optional properties are not required" do
    assert [] = Validex.verify(%{}, [name: [presence: false]])
  end

  test "can verify attributes nested inside maps" do
    assert [
      {:ok, :address, :presence},
      {:ok, :address, :type},
        {:ok, [:address, :country], :presence},
        {:ok, [:address, :country], :type},
        {:ok, [:address, :country, :country_code], :presence},
        {:ok, [:address, :country, :country_code], :type},
        {:ok, [:address, :country, :iso_code], :presence},
        {:ok, [:address, :country, :iso_code], :type},
        {:error, [:address, :country, :name], :presence, _},
        {:ok, [:address, :street_name], :presence},
        {:ok, [:address, :street_name], :type},
        {:ok, [:address, :zip_code], :presence},
        {:ok, [:address, :zip_code], :type}
    ] = Validex.verify(%{
      address: %{
        zip_code: 90210, street_name: "Rodeo Drive",
        country: %{ iso_code: "US", country_code: 1 }
      }
    }, [address: %{
         zip_code: :integer, street_name: :string,
         country: %{ iso_code: :string, country_code: :integer, name: :string }
    }])
  end

  test "required nested attributes of optional parent is only verified if parent is present" do
    assert [] = Validex.verify(
      %{},
      [address: [presence: false, nested: %{ country: [presence: true, type: :string] }]]
    )
  end

  test "required nesting attributes have implicit type" do
    assert [
      {:ok, :address, :presence},
      {:error, :address, :type, "address should be map but was integer"}
    ] = Validex.verify(
        %{ address: 5 },
        [address: %{ country: [presence: false] }]
    )
  end

  test "optional nesting attributes have implicit type" do
    assert [
      {:error, :address, :type, "address should be map but was integer"}
    ] = Validex.verify(
        %{ address: 5 },
        [address: [presence: false, nested: %{ country: [presence: false] }]]
    )
  end

  test "unknown validators are errors" do
    assert [
      {:error, :name, :__validex__unknown_validator__, "name has unknown validator wtfbbq with spec :roflcopter"}
    ] = Validex.errors(%{ name: "simon" }, [name: [wtfbbq: :roflcopter]])
  end

end
