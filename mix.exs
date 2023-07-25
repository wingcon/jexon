defmodule Jexon.MixProject do
  use Mix.Project

  def project do
    [
      app: :jexon,
      version: "0.9.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Jexon is an Elixir library enabling a seamless connection between Elixir data structures and JSON, while maintaining unique Elixir types not directly supported in JSON",
      licenses: ~w(MIT),
      links: %{
        "Github" => "https://github.com/wingcon/jexon"
      }
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
      {:jason, "~> 1.4.1"}
    ]
  end
end
