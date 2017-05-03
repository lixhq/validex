# Validex [![Build Status](https://travis-ci.org/lixhq/validex.svg?branch=master)](https://travis-ci.org/lixhq/validex) [![Coverage Status](https://coveralls.io/repos/github/lixhq/validex/badge.svg?branch=master)](https://coveralls.io/github/lixhq/validex?branch=master) [![Inline docs](http://inch-ci.org/github/lixhq/validex.svg?branch=master&style=shields)](http://inch-ci.org/github/lixhq/validex)

Validex is a library for doing data validation in Elixir. 

At [Lix](https://www.lix.com) we use it to ensure all data entering our domain is fully validated. One goal of Validex is to make schema definitions easy to read and write using intuitive syntax.

Validex is easily extendable and allow you to specify custom validators by implementing the [Validex.Validator](https://hexdocs.pm/validex/Validex.Validator.html) behaviour. Another extensionpoint is custom [Validex.RuleExpander](https://hexdocs.pm/validex/Validex.RuleExpander.html), that allow for rewriting the schema in order to have custom shorthands for a larger schema. One example of this can be seen [here](https://github.com/lixhq/validex/blob/master/test/support/rule_expanders.ex#L16-L23).

## Installation

The package can be installed by adding `validex` 
to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:validex, "~> 0.1"}]
end
```

## Usage

```elixir
schema = [name: :string, age: :integer, sex: :atom]
data = %{ name: "Simon", age: :ripe }

false = Validex.valid?(data, schema)

[
  {:error, :age, :type, "age should be integer but was atom" },
  {:error, :sex, :presence, "sex is a required attribute but was absent"}
] = Validex.errors(data, schema)
```

## Documentation

Documentation can be found at [https://hexdocs.pm/validex](https://hexdocs.pm/validex).

## Prior art

- [PropTypex](https://github.com/lixhq/proptypex) which were the previous library we wrote for doing data validation.
- [Vex](https://github.com/CargoSense/vex) A now aboned validation library by the people behind [Absinthe](http://absinthe-graphql.org/)

## License

Released under the [MIT License](http://www.opensource.org/licenses/MIT).
