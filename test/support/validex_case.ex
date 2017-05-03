defmodule Validex.ValidexCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      defp add_expander(expander) do
        Agent.update(Validex, &Map.update!(&1, :expanders, fn expanders ->
          [expander | expanders]
        end))
      end
    end
  end

  setup_all do
    Validex.verify(%{}, [prop: [presence: false]])
    reset_expanders()
  end

  setup do
    on_exit(&reset_expanders/0)
  end


  defp reset_expanders() do
    if Process.whereis(Validex) do
      Agent.update(Validex, &Map.update!(&1, :expanders, fn expanders -> expanders -- [Validex.RuleExpanderTest.OptionalByDefault, Validex.RuleExpanderTest.Currency] end))
    else
      :ok
    end
  end
end

