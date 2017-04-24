# Validex

Validex is a library for doing data validation in Elixir.

## Examples

```elixir
schema = [name: :string, age: :integer, sex: :atom]
data = %{ name: "Simon", age: :ripe }

false = Validex.valid?(data, schema)

[
  {error, :age, :type, "age should be integer but was atom" },
  {:error, :sex, :presence, "sex is a required attribute but was absent"}
] = Validex.errors(data, schema)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `validex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:validex, "~> 0.1.0"}]
end
```

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/validex](https://hexdocs.pm/validex).

