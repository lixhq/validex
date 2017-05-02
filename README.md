# Validex [![Build Status](https://travis-ci.org/lixhq/validex.svg?branch=master)](https://travis-ci.org/lixhq/validex)

Validex is a library for doing data validation in Elixir.

## Examples

```elixir
schema = [name: :string, age: :integer, sex: :atom]
data = %{ name: "Simon", age: :ripe }

false = Validex.valid?(data, schema)

[
  {:error, :age, :type, "age should be integer but was atom" },
  {:error, :sex, :presence, "sex is a required attribute but was absent"}
] = Validex.errors(data, schema)
```

## Installation

The package can be installed by adding `validex` 
to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:validex, "~> 0.1.0"}]
end
```

## Documentation

Documentation can be found at [https://hexdocs.pm/validex](https://hexdocs.pm/validex).

