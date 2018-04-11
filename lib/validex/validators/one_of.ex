defmodule Validex.Validators.OneOf do
  use Validex.Validator
  require Logger

  def validate(_, attribute, types, value, options) when is_list(types) do
    result =
      Enum.reduce(types, %{success: [], errors: []}, fn type, validations ->
        inner_value = %{attribute => value}
        schema = Keyword.new([{attribute, type}])
        res_type = if Validex.valid?(inner_value, schema, options), do: :success, else: :errors
        Map.update!(validations, res_type, &(&1 ++ Validex.verify(inner_value, schema, options)))
      end)

    if [] == result.success do
      [
        {:error, attribute, :one_of,
         "#{attribute} should be one of #{inspect(types)} but was #{inspect(value)}"}
        | result.errors
      ]
    else
      [{:ok, attribute, :one_of} | result.success]
    end
  end
end
