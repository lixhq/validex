defmodule Validex.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :validex,
     version: @version,
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "A data validation library for Elixir",
     deps: deps(),
     package: package(),
     docs: docs()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev, runtime: false}]
  end

  defp package do
    [
     maintainers: ["Simon Stender Boisen"],
     licenses: ["MIT License"],
     links: %{ github: "https://github.com/lixhq/validex" }
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
end
