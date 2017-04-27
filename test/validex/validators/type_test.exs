defmodule TypeTest do
  use ExUnit.Case, async: true

  def do_type_test(type, value, :ok) do
    assert [{:ok, :prop, :presence}, {:ok, :prop, :type}
    ] = Validex.verify(%{ prop: value}, [prop: [type: type]])
  end

  def do_type_test(type, value, :error) do
    assert [{:ok, :prop, :presence}, {:error, :prop, :type, _}
    ] = Validex.verify(%{ prop: value}, Keyword.new([{:prop, type}]))
  end
end

