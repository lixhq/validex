defmodule Validex.Validators.OneOf do
  use Validex.Validator
  require Logger

  def validate(attribute, types, value) when is_list(types) do
    result = Enum.reduce(types, %{ success: [], errors: [] }, fn type, validations ->
      inner_value = %{ attribute => value }
      schema = Keyword.new([{attribute, type}])
      res_type = if Validex.valid?(inner_value, schema), do: :success, else: :errors
      Map.update!(validations, res_type, &(&1 ++ Validex.verify(inner_value, schema)))
    end)

    if [] == result.success do
      [{:error, attribute, :one_of, "#{attribute} should be one of #{inspect types} but was #{inspect value}"} | result.errors]
    else
      [{:ok, attribute, :one_of} | result.success]
    end

  end
end
