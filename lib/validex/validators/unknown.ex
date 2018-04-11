defmodule Validex.Validators.Unknown do
  use Validex.Validator

  def validate(rule_kind, attribute, rule_spec, _, _) do
    [
      {:error, attribute, :__validex__unknown_validator__,
       "#{attribute} has unknown validator #{rule_kind} with spec #{inspect(rule_spec)}"}
    ]
  end
end
