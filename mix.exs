defmodule Validex.Mixfile do
  use Mix.Project

  @version "0.6.2"

  def project do
    [
      app: :validex,
      version: @version,
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: "A data validation library for Elixir",
      deps: deps(),
      package: package(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:inch_ex, only: :docs},
      {:excoveralls, "~> 0.6", only: :test}
    ]
  end

  defp package do
    [
      maintainers: ["Simon Stender Boisen"],
      licenses: ["MIT License"],
      links: %{github: "https://github.com/lixhq/validex"}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/validex",
      main: "Validex",
      source_url: "https://github.com/lixhq/validex"
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
