defmodule Baconmail.MixProject do
  use Mix.Project

  def project do
    [
      app: :baconmail,
      version: "0.1.0",
      elixir: "~> 1.9",
      escript: [main_module: Baconmail.CLI],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :gmail]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gmail, "~> 0.1"},
      {:yaml_elixir, "~> 2.4"},
    ]
  end
end
