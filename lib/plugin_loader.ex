defmodule Validex.PluginLoader do
  @moduledoc """
  Used for loading RuleExpanders and Validators.
  """

  @doc """
  Loads all plugins in all code paths.

  Adopted from http://stackoverflow.com/a/36435699/359137
  """
  @spec load_all(:atom) :: [] | [atom]
  def load_all(behaviour) do
    get_plugins(behaviour)
  end

  # Loads all modules that extend a given module in the current code path.
  @spec get_plugins(atom) :: [] | [atom]
  defp get_plugins(plugin_type) when is_atom(plugin_type) do
    available_modules(plugin_type) |> Enum.reduce([], &load_plugin/2)
  end

  defp load_plugin(module, modules) do
    if Code.ensure_loaded?(module), do: [module | modules], else: modules
  end

  defp available_modules(plugin_type) do
    # Ensure the current projects code path is loaded
    Mix.Task.run("loadpaths", [])
    # Fetch all .beam files
    Path.wildcard(Path.join([Mix.Project.build_path, "**/ebin/**/*.beam"]))
    # Parse the BEAM for behaviour implementations
    |> Stream.map(fn path ->
      {:ok, {mod, chunks}} = :beam_lib.chunks('#{path}', [:attributes])
      {mod, get_in(chunks, [:attributes, :behaviour])}
    end)
    # Filter out behaviours we don't care about and duplicates
    |> Stream.filter(fn {_mod, behaviours} -> is_list(behaviours) && plugin_type in behaviours end)
    |> Enum.uniq
    |> Enum.map(fn {module, _} -> module end)
  end
end
