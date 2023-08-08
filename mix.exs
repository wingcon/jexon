defmodule Jexon.MixProject do
  use Mix.Project

  def project do
    [
      app: :jexon,
      version: "0.9.3",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Jexon is an Elixir library enabling a seamless connection between Elixir data structures and JSON, while maintaining unique Elixir types not directly supported in JSON",
      description: description(),
      package: package(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4.1"},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    Jexon is an Elixir library enabling a seamless connection between Elixir data structures and JSON, while maintaining unique Elixir types not directly supported in JSON
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: "wingcon",
      licenses: ~w(MIT),
      links: %{"Github" => "https://github.com/wingcon/jexon"}
    ]
  end
end
